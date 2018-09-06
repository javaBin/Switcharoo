package no.javazone.switcharoo.api;

import com.google.gson.Gson;
import no.javazone.switcharoo.service.ProgramService;

public class Program implements HttpService {

    private final ProgramService program;

    public Program(ProgramService program) {
        this.program = program;
    }
    @Override
    public void register(Gson gson) {
        spark.Spark.get("/program", (req, res) -> {
            res.type("application/json");
            return gson.toJson(program.sessions());
        });
    }
}
