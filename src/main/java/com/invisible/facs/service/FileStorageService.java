package com.invisible.facs.service;

import com.invisible.facs.config.StorageProperties;
import jakarta.annotation.PostConstruct;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@Slf4j
@Service
@EnableConfigurationProperties(StorageProperties.class)
public class FileStorageService {

    private static final Map<String, String> EXTENSION_BY_TYPE = new HashMap<>();
    static {
        EXTENSION_BY_TYPE.put("image/jpeg", ".jpg");
        EXTENSION_BY_TYPE.put("image/png", ".png");
        EXTENSION_BY_TYPE.put("image/webp", ".webp");
        EXTENSION_BY_TYPE.put("application/pdf", ".pdf");
    }

    @Autowired
    private StorageProperties properties;

    @PostConstruct
    public void ensureRoot() throws IOException {
        Path root = rootPath();
        Files.createDirectories(root);
        log.info("File uploads root: {}", root.toAbsolutePath());
    }

    public String store(MultipartFile file, String subfolder) {
        if (file == null || file.isEmpty()) return null;
        String contentType = file.getContentType();
        String extension = null;
        if (contentType != null) {
            extension = EXTENSION_BY_TYPE.get(contentType);
        }
        if (extension == null) {
            throw new IllegalArgumentException("Unsupported file type");
        }

        String filename = UUID.randomUUID() + extension;
        Path dir = rootPath().resolve(subfolder);
        try {
            Files.createDirectories(dir);
            Path target = dir.resolve(filename);
            InputStream in = file.getInputStream();
            try {
                Files.copy(in, target, StandardCopyOption.REPLACE_EXISTING);
            } finally {
                in.close();
            }
            return properties.getUrlPrefix() + "/" + subfolder + "/" + filename;
        } catch (IOException e) {
            throw new IllegalStateException("Failed to store file", e);
        }
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
