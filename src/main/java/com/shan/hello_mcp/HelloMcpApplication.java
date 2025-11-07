package com.shan.hello_mcp;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class HelloMcpApplication {

	public  static Logger log = LoggerFactory.getLogger(HelloMcpApplication.class);
	public static void main(String[] args) {
		SpringApplication.run(HelloMcpApplication.class, args);
		log.info("Hello MCP Application started.");

	}

}
