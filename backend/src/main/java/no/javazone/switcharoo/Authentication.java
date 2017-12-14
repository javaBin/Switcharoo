package no.javazone.switcharoo;

import com.auth0.jwt.JWT;
import com.auth0.jwt.JWTVerifier;
import com.auth0.jwt.algorithms.Algorithm;
import com.auth0.jwt.interfaces.DecodedJWT;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import spark.Request;

import java.io.UnsupportedEncodingException;

public class Authentication {

    static Logger LOG = LoggerFactory.getLogger(Authentication.class);

    private final JWTVerifier verifier;

    public Authentication(String secret, String issuer) throws UnsupportedEncodingException {
        this.verifier = creaetVerifier(secret, issuer);
    }

    public boolean verify(Request req) {
        String authorization = req.headers("authorization");
        if (authorization == null) {
            return false;
        }
        authorization = authorization.replace("Bearer ", "");

        try {
            verifier.verify(authorization);
            return true;
        } catch (RuntimeException e) {
            LOG.warn("Error verifying auth header", e);
            return false;
        }
    }

    private JWTVerifier creaetVerifier(String secret, String issuer) throws UnsupportedEncodingException {
        Algorithm algorithm = Algorithm.HMAC256(secret);
        return JWT.require(algorithm)
                .withIssuer(issuer)
                .build();
    }

}
