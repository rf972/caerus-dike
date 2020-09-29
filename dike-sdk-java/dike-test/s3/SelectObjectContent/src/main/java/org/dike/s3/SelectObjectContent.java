package org.dike.s3;

import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3ClientBuilder;
import com.amazonaws.client.builder.AwsClientBuilder;
import com.amazonaws.services.s3.model.CSVInput;
import com.amazonaws.services.s3.model.CSVOutput;
import com.amazonaws.services.s3.model.CompressionType;
import com.amazonaws.services.s3.model.ExpressionType;
import com.amazonaws.services.s3.model.InputSerialization;
import com.amazonaws.services.s3.model.OutputSerialization;
import com.amazonaws.services.s3.model.SelectObjectContentEvent;
import com.amazonaws.services.s3.model.SelectObjectContentEventStream;
import com.amazonaws.services.s3.model.SelectObjectContentEventVisitor;
import com.amazonaws.services.s3.model.SelectObjectContentRequest;
import com.amazonaws.services.s3.model.SelectObjectContentResult;

import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.util.concurrent.atomic.AtomicBoolean;
import static com.amazonaws.util.IOUtils.copy;

public class SelectObjectContent {
    //sql-test/TotalPopulation.csv
    private static final String BUCKET_NAME = "sql-test";
    //private static final String CSV_OBJECT_KEY = "TotalPopulation.csv";
    private static final String CSV_OBJECT_KEY = "5m-Sales-Records.csv";
    private static final String QUERY = "SELECT COUNT(*) FROM s3object";

    public static void main(String[] args) {
        final AmazonS3 s3client = AmazonS3ClientBuilder.standard()
                .withEndpointConfiguration(new AwsClientBuilder.EndpointConfiguration("http://172.18.0.2:9000","us-east-1"))
                .build();
                
        SelectObjectContentRequest request = generateBaseCSVRequest(BUCKET_NAME, CSV_OBJECT_KEY, QUERY);
        final AtomicBoolean isResultComplete = new AtomicBoolean(false);
        String res;

        try (SelectObjectContentResult result = s3client.selectObjectContent(request);
                SelectObjectContentEventStream payload = result.getPayload();
                ByteArrayOutputStream out = new ByteArrayOutputStream()) {
                    InputStream resultInputStream = payload.getRecordsInputStream(new SelectObjectContentEventVisitor() {
                        @Override
                        public void visit(SelectObjectContentEvent.EndEvent event) {
                            isResultComplete.set(true);
                        }
                });
            copy(resultInputStream, out);
            res = out.toString().trim();
        } catch (Throwable e) {
            System.out.println("SQL query failure");
            throw new RuntimeException("SQL query failure", e);
        }

        /*
        * The End Event indicates all matching records have been transmitted.
        * If the End Event is not received, the results may be incomplete.
        */
        if (!isResultComplete.get()) {
            throw new RuntimeException("S3 Select request was incomplete as End Event was not received.");
        }

        System.out.println(res);

    }

    private static SelectObjectContentRequest generateBaseCSVRequest(String bucket, String key, String query) {
        SelectObjectContentRequest request = new SelectObjectContentRequest();
        request.setBucketName(bucket);
        request.setKey(key);
        request.setExpression(query);
        request.setExpressionType(ExpressionType.SQL);

        InputSerialization inputSerialization = new InputSerialization();
        inputSerialization.setCsv(new CSVInput());
        inputSerialization.setCompressionType(CompressionType.NONE);
        request.setInputSerialization(inputSerialization);

        OutputSerialization outputSerialization = new OutputSerialization();
        outputSerialization.setCsv(new CSVOutput());
        request.setOutputSerialization(outputSerialization);

        return request;
    }
}
