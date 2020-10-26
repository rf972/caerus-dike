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
import java.nio.ByteBuffer;
import java.io.InputStream;
import java.util.concurrent.atomic.AtomicBoolean;



class S3SelectThread extends Thread {
    public String BUCKET_NAME;
    public String CSV_OBJECT_KEY;
    public String QUERY;

    public void run(){
       System.out.println("MyThread running");
       final AmazonS3 s3client = AmazonS3ClientBuilder.standard()
       .withEndpointConfiguration(new AwsClientBuilder.EndpointConfiguration("http://172.18.0.2:9000","us-east-1"))
       .build();
       
        SelectObjectContentRequest request = generateBaseCSVRequest(BUCKET_NAME, CSV_OBJECT_KEY, QUERY);
        final AtomicBoolean isResultComplete = new AtomicBoolean(false);
        String res = "";
        long totalDataSize = 0;        

        long start_time = System.currentTimeMillis();
        try (
        SelectObjectContentResult result = s3client.selectObjectContent(request);
        SelectObjectContentEventStream payload = result.getPayload();
        ByteArrayOutputStream out = new ByteArrayOutputStream()
        ) 
        {
            InputStream resultInputStream = payload.getRecordsInputStream(new SelectObjectContentEventVisitor() {
                int recordCounter = 0;
                @Override
                public void visit(SelectObjectContentEvent.EndEvent event) {
                    isResultComplete.set(true);
                    //System.out.println("Received EndEvent.");
                }
                @Override
                public void visit(SelectObjectContentEvent.RecordsEvent event) {
                    
                    //ByteBuffer bb = event.getPayload();                    
                    //recordCounter += 1;
                    //System.out.println("Received RecordsEvent : " + recordCounter);
                }
                @Override
                public void visit(SelectObjectContentEvent.ContinuationEvent event) {
                    
                    //System.out.println("Received ContinuationEvent.");
                }

            });   
        
            byte[] buf = new byte[8192];            
            int n = 0;
            while ((n = resultInputStream.read(buf)) > -1) {                
                totalDataSize += n;                
                if (res.length() < 1024) {
                    out.write(buf, 0, n);
                    res = out.toString().trim();                    
                }               
            }            
            out.close();
            resultInputStream.close();

        } catch (Throwable e) {
            throw new RuntimeException("SQL query failure", e);
        }
        long end_time = System.currentTimeMillis();

        if (!isResultComplete.get()) {
            throw new RuntimeException("S3 Select request was incomplete as End Event was not received.");
        }

        if (res.length() < 1024) {
            System.out.println(res);
            System.out.format("Received %d bytes in %.3f sec\n", totalDataSize, (end_time - start_time) / 1000.0);
        } else {
            System.out.format("Received %d bytes in %.3f sec\n", totalDataSize, (end_time - start_time) / 1000.0);
        }
    }
    private static SelectObjectContentRequest generateBaseCSVRequest(String bucket, String key, String query) {
        SelectObjectContentRequest request = new SelectObjectContentRequest();
        request.setBucketName(bucket);
        request.setKey(key);
        request.setExpression(query);
        request.setExpressionType(ExpressionType.SQL);

        InputSerialization inputSerialization = new InputSerialization();

        CSVInput csvInput = new CSVInput();
        csvInput.setFileHeaderInfo("Use");
        csvInput.setRecordDelimiter("\n");
        csvInput.setFieldDelimiter(",");
        csvInput.setComments("#");
        csvInput.setQuoteCharacter("\"");
        csvInput.setQuoteEscapeCharacter("\"");

        inputSerialization.setCsv(csvInput);
        inputSerialization.setCompressionType(CompressionType.NONE);
        request.setInputSerialization(inputSerialization);

        OutputSerialization outputSerialization = new OutputSerialization();
        outputSerialization.setCsv(new CSVOutput());
        request.setOutputSerialization(outputSerialization);

        return request;
    }    
}


public class SelectObjectContent {
    private static  String BUCKET_NAME = "tpch-test";
    private static  String CSV_OBJECT_KEY = "lineitem.csv";
    private static String QUERY = "select s.l_orderkey,s.l_partkey,s.l_suppkey,s.l_linenumber,s.l_quantity,s.l_extendedprice,s.l_discount,s.l_tax,s.l_returnflag,s.l_linestatus,s.l_shipdate,s.l_commitdate,s.l_receiptdate,s.l_shipinstruct,s.l_shipmode,s.l_comment from S3Object s";

    public static void main(String[] args) {               
        int threadCount = 1;

        if (args.length == 3) {
            BUCKET_NAME = args[0];
            CSV_OBJECT_KEY = args[1];
            QUERY = args[2];
        } else if (args.length > 0) {
            QUERY += " " + args[0];
        }
        S3SelectThread s3selectThread[] = new S3SelectThread[threadCount];

        for(int i = 0; i < threadCount; i++) {
            s3selectThread[i] = new S3SelectThread();
            s3selectThread[i].BUCKET_NAME = BUCKET_NAME;
            s3selectThread[i].CSV_OBJECT_KEY = CSV_OBJECT_KEY; // + "." + Integer.toString(i+1);
            s3selectThread[i].QUERY = QUERY;

            s3selectThread[i].start();
        }

        for(int i = 0; i < threadCount; i++) {
            try {
                s3selectThread[i].join();
            } catch (InterruptedException ie) {
                ie.printStackTrace();
            }            
        }
        
        long heapSize = Runtime.getRuntime().totalMemory();
        System.out.println("Heap Size: " + (heapSize >> 20) + "MB");
    }
}
