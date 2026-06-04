package com.invisible.facs.service;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.invisible.facs.config.OcrProperties;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.web.client.RestClient;
import org.springframework.web.multipart.MultipartFile;
import tools.jackson.databind.ObjectMapper;

import java.io.IOException;
import java.util.Base64;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Slf4j
@RequiredArgsConstructor
public class GeminiPlateOcrService implements PlateOcrService {

    private static final String PROMPT = """
            You are a high-precision OCR specialist for Bangladeshi vehicle number plates. Your single job is to read the registration EXACTLY as printed on the metal plate and return JSON only. Return every character byte-for-byte as it appears on the plate.

            ═════════════════════════════════════
            ABSOLUTE RULE — PLATE ONLY
            ═════════════════════════════════════
            Read ONLY the characters printed on the rectangular metal/acrylic number plate itself.
            DO NOT read, include, or be influenced by ANY other text in the image, including but not limited to:
              • stickers, fitness/tax/insurance tokens, dealer decals
              • text on the bumper, body panel, windshield, mudguard, spare tire cover
              • brand names, logos, model badges, country codes
              • advertising, slogans, phone numbers, URLs
              • reflections of nearby text in glass or chrome
            If a character only appears OUTSIDE the metal plate, IT DOES NOT EXIST for you. Pretend it isn't there.
            If multiple plates are visible, pick the ONE that is largest, sharpest, fully in frame, and clearly the vehicle's registration plate.

            ═════════════════════════════════════
            BANGLADESH PLATE LAYOUT
            ═════════════════════════════════════
            Plates are typically two lines on a single metal rectangle:
              Line 1:  {region} - {letter}             e.g.  ঢাকা মেট্রো - গ
              Line 2:  {serial1} - {serial2}            e.g.  ১৫ - ০৫৬৮

            - region: 1–2 words naming the issuing zone (e.g. "ঢাকা", "ঢাকা মেট্রো", "চট্ট মেট্রো", "সিলেট").
            - letter: ZERO or ONE single consonant. SOME PLATES HAVE NO LETTER AT ALL — line 1 may be just the region. If there is no letter on the plate, return letter as empty string "".
            - serial1: EXACTLY 2 digits. No more, no fewer.
            - serial2: EXACTLY 4 digits. No more, no fewer.


            ═════════════════════════════════════
            READING DISCIPLINE — 99.99% CONFIDENCE REQUIRED
            ═════════════════════════════════════
            You may only set confident=true when EVERY single character meets the 99.99% bar. The cost of one wrong character is much worse than returning confident=false. WHEN IN DOUBT, NEVER GUESS.

            For each character position, follow this protocol:
              1. Read the character. Lock in the value.
              2. Read it again from scratch, looking only at that one glyph (don't peek at neighbors). It MUST match step 1.
              3. Read it a third time and name the distinguishing feature. If you cannot name one, the character is ambiguous.
              4. If steps 1, 2, and 3 do not all agree → that field is NOT confident, return confident=false for the entire plate.

            HARD REJECTS (set confident=false immediately):
              • Any character is partially behind a sticker, dirt, glare, frame, or other occlusion.
              • Any character is motion-blurred, out of focus, or pixelated.
              • Any character is cropped at the image edge.
              • You "feel" pretty sure but can't name the distinguishing feature.
              • Two passes disagree about ANY character.

            NEVER infer a character from context, registration patterns, or what a neighbor "suggests". Each character stands alone on its visual evidence.

            ═════════════════════════════════════
            OUTPUT — JSON ONLY (no prose, no markdown, no code fences)
            ═════════════════════════════════════
            Return a single JSON object matching the schema:
              region   : string  (1–2 words naming the issuing zone, as printed)
              letter   : string  (exactly 1 character, OR empty string "" if the plate has no letter)
              serial1  : string  (exactly 2 digits, as printed)
              serial2  : string  (exactly 4 digits, as printed)
              confident: boolean (true only at 99.99% certainty on EVERY character)

            If the plate is unreadable, missing, partly occluded, or ANY single character fails the 99.99% bar, return:
              {"region":"", "letter":"", "serial1":"", "serial2":"", "confident": false}
            """;

    private final OcrProperties properties;
    private final RestClient ocrRestClient;
    private final ObjectMapper objectMapper;

    @Override
    public String providerId() {
        return "gemini:" + properties.getModel();
    }

    @Override
    public boolean enabled() {
        return true;
    }

    @Override
    public Optional<String> extractPlate(MultipartFile image) {
        if (image == null || image.isEmpty())
            return Optional.empty();

        byte[] bytes;
        try {
            bytes = image.getBytes();
        } catch (IOException e) {
            log.warn("Failed to read uploaded image for OCR: {}", e.getMessage());
            return Optional.empty();
        }
        String mime = image.getContentType();
        if (mime == null || mime.isBlank())
            mime = "image/jpeg";

        // Force structured JSON output so the model commits to each field independently
        // —
        // makes single-digit drift much easier to catch and validate server-side.
        Map<String, Object> responseSchema = new LinkedHashMap<>();
        responseSchema.put("type", "OBJECT");
        Map<String, Object> properties = new LinkedHashMap<>();
        properties.put("region", Map.of("type", "STRING"));
        properties.put("letter", Map.of("type", "STRING"));
        properties.put("serial1", Map.of("type", "STRING"));
        properties.put("serial2", Map.of("type", "STRING"));
        properties.put("confident", Map.of("type", "BOOLEAN"));
        responseSchema.put("properties", properties);
        // `letter` is intentionally NOT required — some Bangladeshi plates have no
        // letter segment;
        // the model returns it as an empty string in that case.
        responseSchema.put("required",
                List.of("region", "serial1", "serial2", "confident"));

        Map<String, Object> body = Map.of(
                "contents", List.of(Map.of("parts", List.of(
                        Map.of("inline_data", Map.of(
                                "mime_type", mime,
                                "data", Base64.getEncoder().encodeToString(bytes))),
                        Map.of("text", PROMPT)))),
                // No maxOutputTokens cap: gemini-2.5-pro's hidden thinking tokens are
                // billed against this limit, and a tight cap leaves zero room for the
                // JSON (response comes back with no `parts` and finishReason=MAX_TOKENS).
                // Omitting the field lets the model use its full default output budget.
                "generationConfig", Map.of(
                        "temperature", 0,
                        "responseMimeType", "application/json",
                        "responseSchema", responseSchema));

        String url = this.properties.getBaseUrl()
                + "/models/" + this.properties.getModel()
                + ":generateContent?key=" + this.properties.getApiKey();

        GeminiResponse response;
        try {
            response = ocrRestClient.post()
                    .uri(url)
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(body)
                    .retrieve()
                    .body(GeminiResponse.class);
        } catch (RuntimeException e) {
            log.warn("Gemini OCR request failed: {}", e.getMessage());
            return Optional.empty();
        }

        String json = extractText(response);
        if (json == null || json.isBlank()) {
            log.warn("Gemini OCR returned empty body. finishReason={} promptFeedback={} usage={}",
                    firstFinishReason(response),
                    response == null ? null : response.promptFeedback(),
                    response == null ? null : response.usageMetadata());
            return Optional.empty();
        }

        // Print the EXACT JSON text Gemini sent us, before any parsing. Use this to
        // verify digits are byte-for-byte preserved through the pipeline.
        log.info("Gemini OCR raw response: {}", json);

        PlatePayload payload;
        try {
            payload = objectMapper.readValue(json, PlatePayload.class);
        } catch (Exception e) {
            log.warn("Gemini OCR returned non-JSON or unexpected shape: {} (body={})", e.getMessage(), json);
            return Optional.empty();
        }

        // Print the parsed fields and their codepoint sequences so any silent
        // character conversion would be obvious in the log.
        log.info("Gemini OCR parsed fields: region='{}' letter='{}' serial1='{}' (codepoints={}) " +
                "serial2='{}' (codepoints={}) confident={}",
                payload.region(), payload.letter(),
                payload.serial1(), codepoints(payload.serial1()),
                payload.serial2(), codepoints(payload.serial2()),
                payload.confident());

        Optional<String> assembled = assemble(payload);
        assembled.ifPresent(p -> log.info("Gemini OCR assembled plate: '{}' (codepoints={})", p, codepoints(p)));
        return assembled;
    }

    private static String codepoints(String s) {
        if (s == null)
            return "null";
        StringBuilder sb = new StringBuilder().append('[');
        for (int i = 0; i < s.length();) {
            int cp = s.codePointAt(i);
            if (sb.length() > 1)
                sb.append(' ');
            sb.append(String.format("U+%04X", cp));
            i += Character.charCount(cp);
        }
        return sb.append(']').toString();
    }

    /**
     * Validates the structured payload and assembles the canonical plate string.
     * Rejects anything where the model itself wasn't confident, or where the field
     * shapes don't match a real Bangladeshi plate (serial1=2 digits, serial2=4
     * digits,
     * letter=1 char, consistent script across all digits).
     */
    private static Optional<String> assemble(PlatePayload p) {
        if (p == null || !Boolean.TRUE.equals(p.confident()))
            return Optional.empty();
        String region = trimOrNull(p.region());
        String letter = trimOrNull(p.letter()); // may be null/empty — letter is optional
        String serial1 = trimOrNull(p.serial1());
        String serial2 = trimOrNull(p.serial2());
        if (region == null || serial1 == null || serial2 == null)
            return Optional.empty();

        // Letter is optional: when present it must be exactly 1 codepoint; when absent
        // the
        // plate string omits the "-{letter}" segment entirely.
        if (letter != null && letter.codePointCount(0, letter.length()) != 1) {
            log.warn("Gemini OCR rejected: letter must be empty or exactly 1 character, got '{}'", letter);
            return Optional.empty();
        }

        Script s1 = scriptOf(serial1);
        Script s2 = scriptOf(serial2);
        if (s1 == Script.MIXED || s2 == Script.MIXED || s1 != s2) {
            log.warn("Gemini OCR rejected: mixed-script digits serial1='{}' serial2='{}'", serial1, serial2);
            return Optional.empty();
        }
        if (serial1.length() != 2) {
            log.warn("Gemini OCR rejected: serial1 must be exactly 2 digits, got '{}'", serial1);
            return Optional.empty();
        }
        if (serial2.length() != 4) {
            log.warn("Gemini OCR rejected: serial2 must be exactly 4 digits, got '{}'", serial2);
            return Optional.empty();
        }

        // Canonical Bangladeshi format:
        // with letter: "{region}-{letter} {serial1}-{serial2}"
        // without letter: "{region} {serial1}-{serial2}"
        // (verify-distribution lookup is case-insensitive and exact on this string.)
        String head = (letter == null) ? region : region + "-" + letter;
        return Optional.of(head + " " + serial1 + "-" + serial2);
    }

    private static String trimOrNull(String v) {
        if (v == null)
            return null;
        String t = v.trim();
        return t.isEmpty() ? null : t;
    }

    private enum Script {
        BENGALI, LATIN, MIXED
    }

    private static Script scriptOf(String digits) {
        boolean hasBn = false, hasLatin = false;
        for (int i = 0; i < digits.length(); i++) {
            char c = digits.charAt(i);
            if (c >= '০' && c <= '৯')
                hasBn = true;
            else if (c >= '0' && c <= '9')
                hasLatin = true;
            else
                return Script.MIXED;
        }
        if (hasBn && hasLatin)
            return Script.MIXED;
        if (hasBn)
            return Script.BENGALI;
        if (hasLatin)
            return Script.LATIN;
        return Script.MIXED;
    }

    private static String extractText(GeminiResponse response) {
        if (response == null || response.candidates() == null || response.candidates().isEmpty())
            return null;
        GeminiCandidate c = response.candidates().get(0);
        if (c == null || c.content() == null || c.content().parts() == null || c.content().parts().isEmpty())
            return null;
        return c.content().parts().get(0).text();
    }

    private static String firstFinishReason(GeminiResponse response) {
        if (response == null || response.candidates() == null || response.candidates().isEmpty())
            return null;
        GeminiCandidate c = response.candidates().get(0);
        return c == null ? null : c.finishReason();
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    private record GeminiResponse(
            List<GeminiCandidate> candidates,
            @JsonProperty("promptFeedback") Object promptFeedback,
            @JsonProperty("usageMetadata") Object usageMetadata) {
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    private record GeminiCandidate(
            GeminiContent content,
            @JsonProperty("finishReason") String finishReason) {
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    private record GeminiContent(List<GeminiPart> parts) {
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    private record GeminiPart(@JsonProperty("text") String text) {
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    private record PlatePayload(
            String region,
            String letter,
            String serial1,
            String serial2,
            Boolean confident) {
    }
}
