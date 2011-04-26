package org.osflash.mixins.generator.sprintf
{
	/**
	 * An sprintf implementation in ActionScript 3.
	 * 
	 * <p>
	 * Supported specifiers: <code>cdieEfgGosuxX</code><br/>
	 * Supported flags: <code>+-(space)#0</code><br/>
	 * Supported width: <code>(number); *</code></br>
	 * Supported precision: <code>.(number); .*</code><br/>
	 * Supported length: <code>h</code><br/>
	 * </p>
	 * 
	 * <p>Unsupported parts like length L (long double) will be removed.</p>
	 * 
	 * <p>Each formatter is following the layout <code>%[flags][width][.precision][length]specifier</code>.</p>
	 * 
	 * @param formatString String that containts the text to format.
	 * It can optionally contain embedded format tags that are
	 * substituted by the values specified in subsequent argument(s)
	 * and formatted as requested.
	 * 
	 * The number of arguments following the <code>format</code> parameters should
	 * at least be as much as the number of format tags.
	 * 
	 * The format tags follow C's sprintf() layout.
	 * 
	 * @param args Depending on the format string, the function may expect a sequence of additional arguments, each containing one value to be inserted instead of each %-tag specified in the format parameter, if any.
	 * There should be the same number of these arguments as the number
	 * of %-tags that expect a value.
	 * 
	 * @return The formatted string.
	 * 
	 * @throws Error If the format string is malformed (e.g. containing invalid characters)
	 * 
	 * @see http://www.cplusplus.com/reference/clibrary/cstdio/sprintf.html sprintf on c++.com
	 * @see http://www.ruby-doc.org/doxygen/1.8.2/sprintf_8c-source.html sprintf.c
	 * 
	 * @author Joa Ebert
	 */		
	public function sprintf( format: String, ... args ): String
	{
		var output: String = '';
		var byte: String;
		var list: Array = args;
					
		var i: int = 0;
		var n: int = format.length;
		var errorStart: int;
		var p:*;
		
		while ( i < n )
		{
			byte = format.charAt( i );
			
			if ( byte == '%' )
			{
				byte = format.charAt( ++i );
				
				if ( byte == '%' )
				{
					output += '%';
				}
				else
				{
					//-- reset locals
					p = null;
					
					//Format: %[flags][width][.precision][length]specifier  
					
					//-- flags
					var flagJustifyLeft	: Boolean = false;
					var flagSignForce	: Boolean = false;
					var flagSignSpace	: Boolean = false;
					var flagExtended	: Boolean = false;
					var flagPadZero		: Boolean = false;
					
					while (
							byte == '-'
						||	byte == '+'
						||	byte == ' '
						||  byte == '#'
						||	byte == '0'
					)
					{
						     if ( byte == '-' ) flagJustifyLeft	= true;
						else if ( byte == '+' ) flagSignForce	= true;
						else if ( byte == ' ' ) flagSignSpace	= true;
						else if ( byte == '#' ) flagExtended	= true;
						else if ( byte == '0' ) flagPadZero		= true;

						byte = format.charAt( ++i );
					}
					
					//-- width
					var widthFromArgument: Boolean = false;
					var widthString: String = '';
					
					if ( byte == '*' )
					{
						widthFromArgument = true;
						byte = format.charAt( ++i );
					}
					else
					{
						while (
								byte == '1' || byte == '2'
							||	byte == '3' || byte == '4'
							||	byte == '5' || byte == '6'
							||	byte == '7' || byte == '8'
							||	byte == '9' || byte == '0'
						)
						{
							widthString += byte;
							byte = format.charAt( ++i );
						}
					}
					
					//-- precision
					var precisionFromArgument: Boolean = false;
					var precisionString: String = '';
					
					if ( byte == '.' )
					{
						byte = format.charAt( ++i );
						
						if ( byte == '*' )
						{
							precisionFromArgument = true;
							byte = format.charAt( ++i );
						}
						else
						{
							while (
									byte == '1' || byte == '2'
								||	byte == '3' || byte == '4'
								||	byte == '5' || byte == '6'
								||	byte == '7' || byte == '8'
								||	byte == '9' || byte == '0'
							)
							{
								precisionString += byte;
								byte = format.charAt( ++i );
							}
						}
					}
					
					//-- length
					var lenh: Boolean = false;
					var lenl: Boolean = false;
					var lenL: Boolean = false;
					
					while (
							byte == 'h'
						||	byte == 'l'
						||	byte == 'L'
					)
					{
						     if ( byte == 'h' ) lenh = true;
						else if ( byte == 'l' ) lenl = true;
						else if ( byte == 'L' ) lenL = true;
						
						byte = format.charAt( ++i );
					}
					
					//-- specifier
					var value: String;
					var width: int = int( widthString );
					var precision: int = int( p = precisionString );
					var padChar: String = ( flagPadZero ) ? '0' : ' ';
					
					if ( precisionFromArgument )
					{
						precision = int( p = list.shift() );
					}
						
					if ( widthFromArgument )
					{
						width = int( list.shift() );
					}
							
					switch ( byte )
					{
						case 'c':
							value = String.fromCharCode( int( list.shift() ) & 0xff );
								
							if ( width != 0 )
							{
								value = pad( value, width, flagJustifyLeft, padChar );
							}
							break;
							
						case 'd':
						case 'i':
						case 'o':
							var intValue: int = int( list.shift() );

							if ( lenh ) intValue &= 0xffff;
							
							if ( byte == 'o' )
							{
								value = intValue.toString( 8 );
							}
							else
							{
								value = intValue.toString();
							}
							
							if ( precision != 0 )
							{
								value = pad( value, precision, false, '0' );
							}
							
							if ( intValue > 0 )
							{
								if ( flagSignForce )
								{
									value = '+' + value;
								}
								else
								if ( flagSignSpace )
								{
									value = ' ' + value;
								}
							}
							
							if ( flagExtended && intValue != 0 && byte == 'o' )
							{
								value = '0' + value;
							}
								
							if ( width != 0 )
							{
								value = pad( value, width, flagJustifyLeft, padChar );
							}
							
							if ( intValue == 0 )
							{	
								if ( p != null && p != undefined && p != '' )
								{
									if ( precision == 0 )
									{
										value = '';
									}
								}
							}
							break;
							
						case 'u':
						case 'x':
						case 'X':
							var uintValue: uint = uint( list.shift() );
							
							if ( lenh ) uintValue &= 0xffff;
							
							p = precisionString;
							
							if ( byte == 'x' )
							{
								value = uintValue.toString( 16 );
							}
							else
							if ( byte == 'X' )
							{
								value = uintValue.toString( 16 ).toUpperCase();
							}
							else
							{
								value = uintValue.toString();
							}
							
							if ( precision != 0 )
							{
								value = pad( value, precision, false, '0' );
							}
							
							if ( uintValue > 0 )
							{
								if ( flagSignForce )
									value = '+' + value;
								else if ( flagSignSpace )
									value = ' ' + value;
							}
							
							if ( uintValue != 0 )
							{
								if ( flagExtended )
								{
									if ( byte == 'x' )
									{
										value = '0x' + value;
									}
									else if ( byte == 'X' )
									{
										value = '0X' + value;
									}
								}
							}
								
							if ( width != 0 )
							{
								value = pad( value, width, flagJustifyLeft, padChar );
							}
							
							if ( uintValue == 0 )
							{	
								if ( p != null && p != undefined && p != '' )
								{
									if ( precision == 0 )
									{
										value = '';
									}
								}
							}
							break;
							
						case 'e':
						case 'E':
							var sciVal: Number = Number( list.shift() );

							if ( precision != 0 )
							{
								value = sciVal.toExponential( Math.min( precision, 20 ) );
							}
							else
							{
								value = sciVal.toExponential( 6 );
							}

							if ( flagExtended )
							{
								if ( value.indexOf( '.' ) == -1 )
								{
									value = value.substring( 0, value.indexOf( 'e' ) ) + '.000000' + value.substring( value.indexOf( 'e' ) + 1 );
								}
							}
															
							if ( byte == 'E' )
								value = value.toUpperCase();
								
							if ( width != 0 )
							{
								value = pad( value, width, flagJustifyLeft, padChar );
							}
							break;
							
						case 'f':
							var floatValue: Number = Number( list.shift() );
							
							if ( precision != 0 )
							{
								value = floatValue.toPrecision( precision );
							}
							else
							{
								value = floatValue.toPrecision( 6 );
							}
							
							if ( flagExtended )
							{
								if ( value.indexOf( '.' ) == -1 )
								{
									value += '.000000';
								}
							}
								
							if ( width != 0 )
							{
								value = pad( value, width, flagJustifyLeft, padChar );
							}
							break;
							
						case 'g':
						case 'G':
							var flags: String = '';
							var precs: String = '';
							var len: String = '';
							
							if ( flagJustifyLeft ) flags += '-';
							if ( flagSignForce ) flags += '+';
							if ( flagSignSpace ) flags += ' ';
							if ( flagExtended ) flags += '#';
							if ( flagPadZero ) flags += '0';
					
							if ( p != null && p != undefined && p != '' )
							{
								precs = '.' + precision.toString();
							}
							
							if ( lenh ) len += 'h';
							if ( lenl ) len += 'l';
							if ( lenL ) len += 'L';
							
							var compValue: Number = Number( list.shift() );
							
							var v0: String = sprintf( '%' + flags + precs + len + 'f', compValue );
							var v1: String = sprintf( '%' + flags + precs + len + ( ( byte == 'G' ) ? 'E' : 'e' ), compValue );
							
							value = ( v0.length < v1.length ) ? v0 : v1;
							break;
							
						case 's':
							value = String( list.shift() );
							
							if ( precision != 0 )
							{
								value = value.substring( 0, precision );
							}
								
							if ( width != 0 )
							{
								value = pad( value, width, flagJustifyLeft, padChar );
							}
							break;
						
						case 'p':
						case 'n':
							break;
							
						default:
							throw new Error(
								'Malformed format string "' + format + '" at "'
								+ format.substring( errorStart, i + 1 ) + '"'
							);
					}
					
					output += value;
				}
			}
			else
			{
				output += byte;
			}
				
			errorStart = ++i;
		}
		
		return output;
	}
}

function pad( string: String, length: int, padRight: Boolean, char: String ): String
{
	var i: int = string.length;
	
	if ( padRight )
	{
		while ( i++ < length )
		{
			string += char;
		}
	}
	else
	{
		while ( i++ < length )
		{
			string = char + string;
		}
	}
	
	return string;
}

