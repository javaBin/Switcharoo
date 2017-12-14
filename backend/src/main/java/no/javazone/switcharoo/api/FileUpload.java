package no.javazone.switcharoo.api;


import com.google.gson.Gson;
import io.vavr.control.Try;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.servlet.MultipartConfigElement;
import javax.servlet.http.Part;

import java.io.File;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;

import static spark.Spark.post;


public class FileUpload implements HttpService {

    static Logger LOG = LoggerFactory.getLogger(FileUpload.class);
    private final File uploadDir;

    public FileUpload(String uploadDir) {
        this.uploadDir = new File(uploadDir);
    }

    @Override
    public void register(Gson gson) {
        uploadDir.mkdir();

        post("/image", (req, res) -> {
            req.attribute("org.eclipse.jetty.multipartConfig", new MultipartConfigElement("/temp"));
            Part part = req.raw().getPart("image");
            String[] filename = getFilenameParts(part.getSubmittedFileName());
            Path tempFile = Files.createTempFile(uploadDir.toPath(), filename[0], "." + filename[1]);

            try (InputStream input = part.getInputStream()) {
                Files.copy(input, tempFile, StandardCopyOption.REPLACE_EXISTING);
            } catch (Exception e) {
                LOG.error("Error while uploading file", e);
                res.status(500);
                return "";
            }

            LOG.info("File uploaded: {}", tempFile.toString());
            res.type("application/json");
            return String.format("{\"location\":\"/%s\", \"filetype\":\"%s\"}", tempFile.toString(), getFiletype(part.getContentType()));
        });
    }

    private String[] getFilenameParts(String filename) {
        String[] parts = filename.split("\\.");

        if (parts.length < 2) {
            return new String[]{filename, "unknown"};
        }

        return new String[]{parts[0], parts[parts.length - 1]};
    }

    private String getFiletype(String contentType) {
        if (contentType.indexOf("image") >= 0) {
            return "image";
        } else if (contentType.indexOf("video") >= 0) {
            return "video";
        }

        return "text";
    }
}
