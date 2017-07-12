package com.weatheraly.bigdata;

import java.text.*;
import java.util.Date;

public class NoaaParserTest {
    private static final DateFormat DATE_FORMAT = new SimpleDateFormat("yyyyMMdd");

    private static final int DIRECTION_ANGLE = 1;
    private static final int WIND_SPEED_RATE = 2;
    private static final int SKY_HEIGHT_DIM = 3;
    private static final int SKY_DISTANCE_DIM = 4;
    private static final int AIR_TEMPERATURE = 5;

    //"0181583620999992017041003004+31400+121467FM-12+000499999V0202901N002019999999N000900199+01311+01231101111"
    
    private String stationId;                   // 583620
    private String observationDateString;       // 20170410
    private String observationTimeString;       // 0300

    private int directionAngle;                 // 290
    private int directionAngleQuality;          // 1
    private int windSpeedRate;                  // 0020
    private int windSpeedRateQuality;           // 1
    private int skyHeightDimension;             // 99999
    private int skyHeightDimensionQuality;      // 9
    private int skyDistanceDimension;           // 000900
    private int skyDistanceDimensionQuality;    // 1
    private int airTemperature;                 // 0131
    private int airTemperatureQuality;          // 1

    public void parse(String record) {
        stationId = record.substring(4, 10);
        observationDateString = record.substring(15, 23);
        observationTimeString = record.substring(23, 27);

        String directionAngleString = record.substring(60, 63);
        String directionAngleQualityString = record.substring(63, 64);
        String windSpeedRateString = record.substring(65, 69);
        String windSpeedRateQualityString = record.substring(69, 70);
        String skyHeightDimensionString = record.substring(70, 75);
        String skyHeightDimensionQualityString = record.substring(75, 76);
        String skyDistanceDimensionString = record.substring(78, 84);
        String skyDistanceDimensionQualityString = record.substring(84, 85);
        String airTemperatureString = record.substring(87, 92);
        String airTemperatureQualityString = record.substring(92, 93);
        
        directionAngle = Integer.parseInt(directionAngleString);
        directionAngleQuality = Integer.parseInt(directionAngleQualityString);
        windSpeedRate = Integer.parseInt(windSpeedRateString);
        windSpeedRateQuality = Integer.parseInt(windSpeedRateQualityString);
        skyHeightDimension = Integer.parseInt(skyHeightDimensionString);
        skyHeightDimensionQuality = Integer.parseInt(skyHeightDimensionQualityString);
        skyDistanceDimension = Integer.parseInt(skyDistanceDimensionString);
        skyDistanceDimensionQuality = Integer.parseInt(skyDistanceDimensionQualityString);
        if (airTemperatureString.charAt(0) == '+')
            airTemperature = Integer.parseInt(airTemperatureString.substring(1, 5));
        else
            airTemperature = Integer.parseInt(airTemperatureString);
        airTemperatureQuality = Integer.parseInt(airTemperatureQualityString);
    }

    public String getStationId() {
        return stationId;
    }

    public String getDate() {
        return observationDateString;
    }

    public String getTime() {
        return observationTimeString;
    }

    public int getDirectionAngle() {
        return directionAngle;
    }

    public int getWindSpeedRate() {
        return windSpeedRate;
    }

    public int getSkyHeightDimension() {
        return skyHeightDimension;
    }

    public int getSkyDistanceDimension() {
        return skyDistanceDimension;
    }

    public int getAirTemperature() {
        return airTemperature;
    }

    public boolean isValid(int type) {
        if (isMissing(type))
            return false;
        int quality = 0;
        switch (type) {
            case DIRECTION_ANGLE:
                quality = directionAngleQuality;
                break;
            case WIND_SPEED_RATE:
                quality = windSpeedRateQuality;
                break;
            case SKY_HEIGHT_DIM:
                quality = skyHeightDimensionQuality;
                break;
            case SKY_DISTANCE_DIM:
                quality = skyHeightDimensionQuality;
                break;
            case AIR_TEMPERATURE:
                quality = airTemperatureQuality;
                break;
        }
        if (quality != 0 || quality != 1 || quality != 4
                || quality != 5 || quality !=9 )
            return false;
        return true;
    }

    public boolean isMissing(int type) {
        switch (type) {
            case DIRECTION_ANGLE:
                return directionAngle == 999;
            case WIND_SPEED_RATE:
                return windSpeedRate == 9999;
            case SKY_HEIGHT_DIM:
                return skyHeightDimension == 99999;
            case SKY_DISTANCE_DIM:
                return skyDistanceDimension == 999999;
            case AIR_TEMPERATURE:
                return airTemperature == 9999;
        }
        return false;
    }

    public Date getObservationDate() {
        try {
            return DATE_FORMAT.parse(observationDateString);
        } catch (ParseException e) {
            throw new IllegalArgumentException(e);
        }
    }

}
