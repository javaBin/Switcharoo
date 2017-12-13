package no.javazone.switcharoo;

import com.google.gson.Gson;
import io.vavr.collection.List;
import no.javazone.switcharoo.api.HttpService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

import static spark.Spark.get;

public class Program implements HttpService {

    static Logger LOG = LoggerFactory.getLogger(Program.class);
    private static final List<Integer> program = List.empty();

    public Program(ScheduledExecutorService executor) {
        executor.scheduleAtFixedRate(getProgram, 1, 5 * 60, TimeUnit.SECONDS);
    }

    @Override
    public void register(Gson gson) {
        get("/program", (req, res) -> program.toJavaList(), gson::toJson);
    }

    private final Runnable getProgram = () -> {
        LOG.info("Fetching new program");
    };
}
