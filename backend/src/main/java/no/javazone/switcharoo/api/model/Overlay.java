package no.javazone.switcharoo.api.model;

import io.vavr.collection.HashMap;

import java.util.Map;

public class Overlay {

    public final String image = "/uploads/github5482036896005066393.svg";
    public final Map<String,String> style = HashMap.of("position", "absolute", "bottom", "0", "right", "0", "width", "100px", "height", "100px").toJavaMap();//new String[]{"bottom:0", "right:0", "width:100px", "height:100px"};
}
