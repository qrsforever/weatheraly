package com.weatheraly.bigdata;

import java.io.IOException;

import org.apache.hadoop.io.NullWritable;
import org.apache.hadoop.mapreduce.Reducer;

import org.apache.avro.Schema;
import org.apache.avro.generic.GenericData;
import org.apache.avro.generic.GenericRecord;
import org.apache.avro.mapred.AvroKey;
import org.apache.avro.mapred.AvroValue;

import org.slf4j.Logger;  
import org.slf4j.LoggerFactory;

public class DataParseReducer
    extends Reducer<AvroKey<String>, AvroValue<GenericRecord>, AvroKey<GenericRecord>, NullWritable> {

    private static Logger logger = LoggerFactory.getLogger(DataParseReducer.class);
    Schema schema = null;
    GenericRecord record = null;

    @Override
    protected void setup(Context context) 
        throws IOException, InterruptedException {
        try {
            schema = new Schema.Parser().parse(
                    getClass().getClassLoader().getResourceAsStream("noaarecord.avsc"));
            record = new GenericData.Record(schema);
            // 初始化默认最小值
            record.put("observationTime", "0000");
            record.put("directionAngle", -1);
            record.put("windSpeedRate", -1);
            record.put("skyHeightDimension", -1);
            record.put("skyDistanceDimension", -1);
            record.put("airTemperature", -99);
        } catch(IOException e){
            logger.info("fixme " + e);
        }
    }

    @Override
    public void reduce(AvroKey<String> key, Iterable<AvroValue<GenericRecord>> values, Context context)
        throws IOException, InterruptedException {
        for (AvroValue<GenericRecord> value : values) {
            GenericRecord r = value.datum();
            if ((Integer)record.get("directionAngle") < (Integer) r.get("directionAngle"))
                record.put("directionAngle", r.get("directionAngle"));

            if ((Integer)record.get("windSpeedRate") < (Integer) r.get("windSpeedRate"))
                record.put("windSpeedRate", r.get("windSpeedRate"));

            if ((Integer)record.get("skyHeightDimension") < (Integer) r.get("skyHeightDimension"))
                record.put("skyHeightDimension", r.get("skyHeightDimension"));
            
            if ((Integer)record.get("skyDistanceDimension") < (Integer) r.get("skyDistanceDimension"))
                record.put("skyDistanceDimension", r.get("skyDistanceDimension"));

            if ((Integer)record.get("airTemperature") < (Integer) r.get("airTemperature"))
                record.put("airTemperature", r.get("airTemperature"));
        }
        logger.info("reduce: " + record.toString());
        context.write(new AvroKey(record), NullWritable.get());
    }
}
