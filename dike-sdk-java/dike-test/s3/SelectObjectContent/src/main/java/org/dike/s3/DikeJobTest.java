package org.dike.s3;
import com.amazonaws.AmazonServiceException;
import com.amazonaws.SdkClientException;

import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3ClientBuilder;
import com.amazonaws.client.builder.AwsClientBuilder;
import com.amazonaws.services.s3.model.ObjectMetadata;
import com.amazonaws.services.s3.model.PutObjectRequest;
import com.amazonaws.services.s3.model.GetObjectRequest;
import com.amazonaws.services.s3.model.S3Object;


import java.io.ByteArrayOutputStream;
import java.nio.ByteBuffer;
import java.io.InputStream;
import java.util.concurrent.atomic.AtomicBoolean;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.IOException;

public class DikeJobTest {
    private static String BUCKET_NAME;
    private static String OBJECT_KEY;
    private static String QUERY;
    private static String JOB;

    public static void main(String[] args) {               
        if (args.length == 3) {
            BUCKET_NAME = args[0];
            OBJECT_KEY = args[1];
            QUERY = args[2];
        }       

        try {
            final AmazonS3 s3Client = AmazonS3ClientBuilder.standard()
            .withEndpointConfiguration(new AwsClientBuilder.EndpointConfiguration("http://172.18.0.2:9000","us-east-1"))
            .build();

            JOB = "ObjectKey=" + OBJECT_KEY + "\n";
            JOB += "SQL=" + QUERY;
            // Upload a text string as a new object.
            s3Client.putObject(BUCKET_NAME, OBJECT_KEY + ".job", JOB);

            // Get an object and print its contents.
             S3Object fullObject = s3Client.getObject(new GetObjectRequest(BUCKET_NAME, OBJECT_KEY + ".job"));

            // Read the text input stream one line at a time and display each line.
            BufferedReader reader = new BufferedReader(new InputStreamReader(fullObject.getObjectContent()));
            String line = null;
            while ((line = reader.readLine()) != null) {
                System.out.println(line);
            }
            System.out.println();
            fullObject.close();
        } catch (IOException e) {
            e.printStackTrace();
        } catch (AmazonServiceException e) {
            // The call was transmitted successfully, but Amazon S3 couldn't process 
            // it, so it returned an error response.
            e.printStackTrace();
        } catch (SdkClientException e) {
            // Amazon S3 couldn't be contacted for a response, or the client
            // couldn't parse the response from Amazon S3.
            e.printStackTrace(); 
        }
    }
}
