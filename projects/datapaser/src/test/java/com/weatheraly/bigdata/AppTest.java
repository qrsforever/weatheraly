package com.weatheraly.bigdata;

import junit.framework.Test;
import junit.framework.TestCase;
import junit.framework.TestSuite;

/**
 * Unit test for simple App.
 */
public class AppTest 
    extends TestCase
{

    private NoaaParserTest noaa = new NoaaParserTest();

    /**
     * Create the test case
     *
     * @param testName name of the test case
     */
    public AppTest( String testName ) {
        super( testName );
        noaa.parse("0181583620999992017041003004+31400+121467FM-12+000499999V0202901N002019999999N000900199+01311+01231101111");
    }

    /**
     * @return the suite of tests being tested
     */
    public static Test suite() {
        return new TestSuite( AppTest.class );
    }

    /**
     * Rigourous Test :-)
     */
    public void testApp() {
        assertTrue(noaa.getDirectionAngle() == 290);
        assertTrue(noaa.getWindSpeedRate() == 20);
        assertTrue(noaa.getSkyHeightDimension() == 99999);
        assertTrue(noaa.getSkyDistanceDimension() == 900);
        assertTrue(noaa.getAirTemperature() == 131);
    }
}
