import java.io.*;
import java.security.KeyStore;
import java.security.cert.Certificate;
import java.util.*;
import java.lang.System;

public class Main {

    public static void main(String[] args) throws Exception {
        
        String keystorePath = args[0];
        String keystorePassword = System.getenv("KEYSTORE_PWD");

        System.out.println("keystore path: " + keystorePath + ", keystore pwd: " + keystorePassword);
            
        byte[] keystoreBytes = readFile(keystorePath);

        KeyStore keystore = KeyStore.getInstance(KeyStore.getDefaultType());
        keystore.load(new ByteArrayInputStream(keystoreBytes), keystorePassword.toCharArray());

        System.out.println("Keystore type: " + keystore.getType());
        System.out.println("Keystore provider: " + keystore.getProvider().getName());

        Enumeration<String> aliases = keystore.aliases();
        while (aliases.hasMoreElements()) {
            String alias = aliases.nextElement();
            System.out.println("Alias: " + alias);
            Certificate cert = keystore.getCertificate(alias);
            if (cert != null) {
                System.out.println("Certificate: " + cert);
            }
        }

        Thread.sleep(360_000);
    }

    private static byte[] readFile(String path) throws Exception {
        FileInputStream fileInputStream = new FileInputStream(path);     
        ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
            
        byte[] buffer = new byte[1024];
        int bytesRead;
        while ((bytesRead = fileInputStream.read(buffer)) != -1) {
            byteArrayOutputStream.write(buffer, 0, bytesRead);
        }
            
        fileInputStream.close();
        byteArrayOutputStream.close();
            
        return byteArrayOutputStream.toByteArray();
    }
}