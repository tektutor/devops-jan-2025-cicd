package org.tektutor;

import org.junit.Test;
import org.junit.Before;
import org.junit.After;
import static org.junit.Assert.*;

public class RPNCalculatorTest {

	private double firstNumber;
	private double secondNumber;
	private double result;

	@Before
	public void init() {
		firstNumber = secondNumber = result = 0.0;
	}

	@Test
	public void testSimpleAddition() {
		RPNCalculator rpnCalculator = new RPNCalculator();
		result = rpnCalculator.evaluate( "10 15 +" );
		assertEquals ( 25.0, result, 0.0001 ); 
	}

	@After
	public void cleanUp() {
		firstNumber = secondNumber = result = 0.0;
	}
}	
