package no.javazone.switcharoo.api;

import com.google.gson.Gson;
import no.javazone.switcharoo.api.util.ContentTypes;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Arrays;

import static spark.Spark.get;

public class Static implements HttpService {

    private final String base;
    private final Logger LOG = LoggerFactory.getLogger(Static.class);
    private final String resourcePath;

    public Static(String resourcePath, Path filePath) {
        String userDir = System.getProperty("user.dir");
        Path path = Paths.get(userDir).resolve(filePath);
        base = path.toString();
        this.resourcePath = resourcePath;
    }

    @Override
    public void register(Gson gson) {
        get(resourcePath, (req, res) -> {
            String requestedPath = req.splat().length == 0 ? "" : req.splat()[0];
            String path = String.join("/", filter(requestedPath.split("/")));
            if (isEmpty(path)) {
                path = "index.html";
            }

            Path systemPath = Paths.get(base).resolve(path);
            if (!Files.exists(systemPath) || !Files.isReadable(systemPath) || Files.isDirectory(systemPath)) {
                LOG.info("Requested file not found: " + systemPath.toString());
                res.status(404);
                return "";
            }

            byte[] bytes = Files.readAllBytes(systemPath);

            res.status(200);
            res.type(ContentTypes.get(getFileType(systemPath)));
            return bytes;
        });
    }

    private String[] filter(String[] path) {
        return Arrays.stream(path).filter(p -> !p.equals("..")).toArray(String[]::new);
    }

    private boolean isEmpty(String s) {
        return s == null || s.length() == 0;
    }

    private String getFileType(Path path) {
        String[] parts = path.toString().split("\\.");
        return parts.length >= 2 ? parts[parts.length - 1] : "";
    }
}
