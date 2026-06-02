package com.invisible.facs.service;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.invisible.facs.config.OcrProperties;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.web.client.RestClient;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.Base64;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Slf4j
@RequiredArgsConstructor
public class GeminiPlateOcrService implements PlateOcrService {

    private static final String PROMPT = """
            You are an expert OCR system for Bangladeshi vehicle number plates. Examine the provided image(s) and extract the registration number exactly as printed.

            CRITICAL — preserve original script. If the plate is in Bengali (Bangla), return Bengali characters and Bengali digits. Never translate, transliterate, romanize, or convert between scripts. Do not "normalize" Bengali digits (০-৯) to ASCII digits or vice versa.

            BANGLADESH PLATE LAYOUT (context for parsing)
            Plates are typically two-line:
              Line 1:  <region>-<letter code>         e.g.  ঢাকা মেট্রো-গ
              Line 2:  <serial1>-<serial2>            e.g.  ১৫-০৫৬৮
            - Region: one or two Bengali words (e.g. "ঢাকা", "ঢাকা মেট্রো", "চট্ট মেট্রো", "সিলেট").
            - Letter code: a single Bengali consonant (e.g. ক, খ, গ, ঘ, চ, ছ, …).
            - Serial1: 2 digits. Serial2: 4 digits. All digits in Bengali if the plate is Bengali.

            OUTPUT STRING FORMAT — collapse both lines into one string:
              {region}-{letter} {serial1}-{serial2}

            Spacing rules (apply exactly):
            1. Words inside the region are separated by ONE space.
                   ✓ ঢাকা মেট্রো
            2. NO space on either side of the hyphen between region and letter code.
                   ✓ ঢাকা মেট্রো-গ      ✗ ঢাকা মেট্রো - গ      ✗ ঢাকা মেট্রো -গ
            3. EXACTLY ONE space between the letter code and serial1.
                   ✓ গ ১৫              ✗ গ১৫                  ✗ গ  ১৫
            4. NO space on either side of the hyphen between serial1 and serial2.
                   ✓ ১৫-০৫৬৮            ✗ ১৫ - ০৫৬৮            ✗ ১৫- ০৫৬৮
            5. NO spaces inside any individual serial group.
                   ✓ ০৫৬৮               ✗ ০৫ ৬৮

            Full correct example:  ঢাকা মেট্রো-গ ১৫-০৫৬৮

            WHAT TO IGNORE
            - Stickers, logos, slogans, fitness/tax tokens, advertising, reflections.
            - Text on the bumper, windshield, or body that is not the plate.
            - If multiple plates are visible, choose the clearest, fully legible one.

            CONFIDENCE & REFUSAL — be conservative
            - Return a plate ONLY if you are at least 90% confident that every character is correct.
            - Never guess, infer, or "complete" characters that are blurred, occluded, cropped, glare-washed, or partially out of frame.
            - If ANY single character is ambiguous, return null for the entire plate. Do not return a partial plate.
            - If no plate is present, the image is not a vehicle, or the plate is too low-resolution, return null.

            OUTPUT — plain text only, nothing else
            - On success: output ONLY the plate string (e.g.  ঢাকা মেট্রো-গ ১৫-০৫৬৮).
            - On any uncertainty, absence, or unreadable plate: output exactly the four letters  NONE
            - Do NOT add quotes, labels, prefixes, explanations, markdown, code fences, or any trailing text.
            - Do NOT wrap the answer in JSON.
            """;

    private final OcrProperties properties;
    private final RestClient ocrRestClient;

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
        if (image == null || image.isEmpty()) return Optional.empty();

        byte[] bytes;
        try {
            bytes = image.getBytes();
        } catch (IOException e) {
            log.warn("Failed to read uploaded image for OCR: {}", e.getMessage());
            return Optional.empty();
        }
        String mime = image.getContentType();
        if (mime == null || mime.isBlank()) mime = "image/jpeg";

        Map<String, Object> body = Map.of(
                "contents", List.of(Map.of("parts", List.of(
                        Map.of("inline_data", Map.of(
                                "mime_type", mime,
                                "data", Base64.getEncoder().encodeToString(bytes))),
                        Map.of("text", PROMPT)))),
                "generationConfig", Map.of(
                        "temperature", 0,
                        "maxOutputTokens", 256));

        String url = properties.getBaseUrl()
                + "/models/" + properties.getModel()
                + ":generateContent?key=" + properties.getApiKey();

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

        String text = extractText(response);
        if (text == null) return Optional.empty();
        text = text.trim();
        if (text.isEmpty() || "NONE".equalsIgnoreCase(text)) return Optional.empty();
        return Optional.of(text);
    }

    private static String extractText(GeminiResponse response) {
        if (response == null || response.candidates() == null || response.candidates().isEmpty()) return null;
        GeminiCandidate c = response.candidates().get(0);
        if (c == null || c.content() == null || c.content().parts() == null || c.content().parts().isEmpty()) return null;
        return c.content().parts().get(0).text();
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    private record GeminiResponse(List<GeminiCandidate> candidates) {}

    @JsonIgnoreProperties(ignoreUnknown = true)
    private record GeminiCandidate(GeminiContent content) {}

    @JsonIgnoreProperties(ignoreUnknown = true)
    private record GeminiContent(List<GeminiPart> parts) {}

    @JsonIgnoreProperties(ignoreUnknown = true)
    private record GeminiPart(@JsonProperty("text") String text) {}
}
