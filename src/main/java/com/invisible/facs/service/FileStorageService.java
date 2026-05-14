package com.invisible.facs.service;

import com.invisible.facs.config.StorageProperties;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.Map;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class FileStorageService {

    private static final Map<String, String> EXTENSION_BY_TYPE = Map.of(
            "image/jpeg", ".jpg",
            "image/png", ".png",
            "image/webp", ".webp",
            "application/pdf", ".pdf");

    private final StorageProperties properties;

    @PostConstruct
    public void ensureRoot() throws IOException {
        Path root = rootPath();
        Files.createDirectories(root);
        log.info("File uploads root: {}", root.toAbsolutePath());
    }

    public String store(MultipartFile file, String subfolder) {
        if (file == null || file.isEmpty()) return null;
        String contentType = file.getContentType();
        String extension = (contentType == null) ? null : EXTENSION_BY_TYPE.get(contentType);
        if (extension == null) {
            throw new IllegalArgumentException("Unsupported file type");
        }

        try {
            // Verify the file's first bytes match the declared Content-Type. The Content-Type
            // header is set by the browser and can be spoofed; magic bytes can't be (easily).
            byte[] header = readHeader(file, 12);
            if (!magicMatches(header, contentType)) {
                throw new IllegalArgumentException("File content does not match declared type");
            }

            String filename = UUID.randomUUID() + extension;
            Path dir = rootPath().resolve(subfolder);
            Files.createDirectories(dir);
            Path target = dir.resolve(filename);
            try (InputStream in = file.getInputStream()) {
                Files.copy(in, target, StandardCopyOption.REPLACE_EXISTING);
            }
            return properties.getUrlPrefix() + "/" + subfolder + "/" + filename;
        } catch (IOException e) {
            throw new IllegalStateException("Failed to store file", e);
        }
    }

    private static byte[] readHeader(MultipartFile file, int max) throws IOException {
        try (InputStream in = file.getInputStream()) {
            byte[] buf = new byte[max];
            int read = 0;
            while (read < max) {
                int n = in.read(buf, read, max - read);
                if (n < 0) break;
                read += n;
            }
            if (read == max) return buf;
            byte[] truncated = new byte[read];
            System.arraycopy(buf, 0, truncated, 0, read);
            return truncated;
        }
    }

    private static boolean magicMatches(byte[] h, String contentType) {
        return switch (contentType) {
            case "image/jpeg" -> h.length >= 3
                    && (h[0] & 0xFF) == 0xFF && (h[1] & 0xFF) == 0xD8 && (h[2] & 0xFF) == 0xFF;
            case "image/png" -> h.length >= 8
                    && (h[0] & 0xFF) == 0x89 && h[1] == 'P' && h[2] == 'N' && h[3] == 'G'
                    && h[4] == 0x0D && h[5] == 0x0A && h[6] == 0x1A && h[7] == 0x0A;
            case "image/webp" -> h.length >= 12
                    && h[0] == 'R' && h[1] == 'I' && h[2] == 'F' && h[3] == 'F'
                    && h[8] == 'W' && h[9] == 'E' && h[10] == 'B' && h[11] == 'P';
            case "application/pdf" -> h.length >= 4
                    && h[0] == '%' && h[1] == 'P' && h[2] == 'D' && h[3] == 'F';
            default -> false;
        };
    }

    public void delete(String urlPath) {
        if (urlPath == null || urlPath.isBlank()) return;
        String prefix = properties.getUrlPrefix();
        if (!urlPath.startsWith(prefix + "/")) return;
        String relative = urlPath.substring(prefix.length() + 1);
        Path target = rootPath().resolve(relative);
        try {
            Files.deleteIfExists(target);
        } catch (IOException e) {
            log.warn("Failed to delete {}: {}", urlPath, e.getMessage());
        }
    }

    private Path rootPath() {
        return Paths.get(properties.getDir()).toAbsolutePath().normalize();
    }
}
