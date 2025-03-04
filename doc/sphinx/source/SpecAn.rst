###############
SpecAn Module
###############

The SpecAn Module is an IVI compliant module.  The properties and methods used for this instrument may be generalized at a later date.

Class Specification
====================

SpecAnBaseClass
+++++++++++++++

All other Spectrum Analyzers classes inherit from the SpecAnBase class.  

|image0|

Figure \: SpecAnBaseClass Properties UML Specification

Properties
~~~~~~~~~~

Acquisition \: Struct
 A structure containing the properties of each module which pertain to the acquisition.  
	
	Handle \: String
	  A unique identifier of the hardware supporting the acquisition.
	  
	Connected \: Boolean
	  Used by the system and not end-user settable.  Indicates that the module has been initialized and is ready to receive further commands.  Closing an acquisition disconnects the acquisition and resets Connected.

	Enabled \: Boolean
	  Set by the end user to determine if the hardware should be enabled or disabled.
  
	SweepModeContinuous \: Boolean
	  If true the sweep mode is acquiried continuously and if false the sweep mode is not continuous. 
	  
	NumberOfSweeps \: Int32
	  Determines the number of sweeps to acquire. A Sweep is definied by adjusting the frequency of the tuner from the start frequency to the stop frequency in a defined amount of time.  
  
	DetectorTypeAuto \: Boolean
	  Set by the user to allow the API to automatically select the detector type.  
	 
	DetectorType \: Enum
	  Specifies the detection method used (Average, Maximum Peak, etc) to capture and process the signal.
	 
	VerticalScale \: Enum
	 Specifies the vertical scale (log amplifiers versus linear amplifiers) of the measurment hardware.
	 
	MaximumTime \: Double
	 Specifies the maximum amount of time in seconds that the fetch or read function will attempt to retrieve data before the funciton returns. 
	 
Frequency \: Struct
 A structure containing the properties of each module which pertain to the Frequency.   
	
	FrequencyStart \: Double
	  Specifies the left edge of the frequency domain. This is used in conjunction with the Frequency Stop property to define the frequency domain. If the Frequency start is equal to the Frequency Stop attribute value then the spectrum analyzer's horizontal attributes are in the time-domain. 
	  
	FrequencyStop \: Double
	  Specifies the right edge of the frequency domiain. This is used in conjunction with the Frequency Start property to define the frequency domain. If the Frequency start is equal to the Frequency Stop attribute value then the spectrum analyzer's horizontal attributes are in the time-domain. 
	  
	FrequencyOffset \: Double
	  Specifies an offset value, in Hertz, that is added to the frequency readout. The offset is used to compensate for external frequency conversion. This changes the driver's Frequency Start and Stop attributes. The equations relating the affected values are  

		
		Frequency Start = Actual Start Frequency + Frequency Offset
	
		Frequency Stop = Actual Stop Frequency + Frequency Offset
	  

Level \: Struct
 A structure containing the properties of each module which pertain to the input signal level.    

	AmplitudeUnits \: Enum
	  Specifies the unit (dBm, dBmV, dBuV, or etc) for input, output, and display. 
	  
	InputImpedance \: Double
	  Specifies the value of the input impedance in ohms expected at the active input port. This is typically 50 or 75 ohms. 
  
	ReferenceLevel \: Double
	  The calibrated vertical poition of the captured data used as a reference for amplitude measurements. This is typically a value slightly higher than the largest expected signal level. The units are determined by the Amplitude Units attribute.  
	 
	ReferenceLevelOffset \: Double
	  Specifies an offset for the Reference Level attribute. This value is used to adjust the reference level for the external signal gain or loss. A positive value corresponds to a gain while a negative number corresponds to a loss. Th value is in dB.
	 
	AttenuationAuto \: Boolean
	  If set to True, the attenuation is automatically selected otherwise the resolution bandwidth must be set by the user. 
	 
	Attenuation \: Double
	  Specifies the input attenuation in positive dB.
	   
	  
SweepCoupling \: Struct
 A structure containing the properties of each sweep. A sweep is thought of as adjusting the frequency of a tuner from the start frequency to the stop frequency in a defined amount of time.    

	ResolutionBandwidthAuto \: Boolean
	  If set to True, the resolution bandwidth is automatically selected otherwise the resolution bandwidth must be set by the user. 
	  
	ResolutionBandwidth \: Double
	  Specifies the width of the IF filter in Hertz. See notes.    
	  
	VideoBandwidthAuto \: Boolean
	  If set to True, the video bandwidth is automatically selected. If set to False, the video bandwidth should be selected by the user.
	 
	VideoBandwidth \: Double
	  Specifies the video bandwidth of the post-detection filter in Hertz. See notes.
	 
	SweepTimeAuto \: Boolean
	  If set to True, the swee time is automatically selected otherwise the swee time must be set by the user. 
	 
	SweepTime \: Double
	  Specifies the lenght of time to sweep from the left edge to the right edge of the current domain. The units are in seconds. See notes.
	  
Notes\: ResolutionBandwidthAuto, ResolutionBandwidth, VideoBandwidth, SweepTime

  Taken from the IVI-4.8: IviSpecAn Class Specification 4.1.1 Sweep Coupling Overview 

  Many spectrum analyzers are capable of coupling the resolution bandwidth, video bandwidth, and sweep time together. The instrument makes decisions based on the various settings to ensure the accuracy of the measurement. If the user elects to choose the settings, it is possible to place constraints on the system that make accurate measurements impossible. Most analyzers respond to this condition with a message indicating that the measurement is uncalibrated. When all the settings are coupled, the instrument makes decisions along the following hierarchy. The RBW and VBW are typically locked together and set for 1% of the span. For example, if the span were set for 100 MHz, the instrument chooses 1 MHz for the RBW and VBW. To measure very low signal levels, the RBW may need to be more narrowed, which slows the sweep speed. Lastly, the sweep time is dependent on the RBW and the VBW. As a rule of thumb:

  Sweep Time = k* Span / RBW^2

  The value of k is in the 2 to 3 range for filters used in some instruments. As can be seen from the above equation, the RBW has a drastic effect on sweep speed. These are issues to keep in mind when developing automated tests. When considering interchangeability and measurement accuracy, it is important to consider the way different instruments couple settings together. The valid combination of RBW, VBW, and sweep time on one spectrum analyzer may not be a valid combination on another spectrum analyzer. Awareness of these differences ensures that the results obtained in one system correlate with the results from another system.

Trace \: [Struct]
 An array of structures containing the properties of each trace.  

	TraceName \: String
	  Returns the pysical repeated capability identify by the specific driver for the item that corresponds to the index that the user specifies. If the driver defines a qualified trace name, this property returns the qualified name. 
  
	TraceSize \: Int32
	  Returns the number of points in the trace array. 
	  
	TraceType \: Enum
	  Specifies the represtation of the acquired data (Video Average, View, Store, etc). 

|image1|

Figure \: SpecAnBaseClass Methods UML Specification

Methods
~~~~~~~

Abort()
  This function stops a previously initiated measurement and returns the spectrum analyzer to the idle state. This function does not check instrument status. 
  
AcquisitionStatus()
  This function determines and returns the status of an acquisition. 
  
Close()
  This function closes the reference to the instrument and sets the connected boolean to false.  
  
ConfigureAcquisition()
  This function configures the acquistion attributes of the spectrum analyzer such as SweepModeContinuous or NumberofSweeps.

ConfigureFrequncy()
  This function configures the frequency range, center frequency, and frequency offset.If the frequency range is equal to zero then the spectrum analyzer operates in the time-domain mode. Inputs to this function are the offset, start, and stop.  
   
ConfigureLevel()
  This function configures the vertical attributes of the spectrum analyzer. This corresponds to the Amplitude Units, Input Attenuation, Input Impedance, Reference Level, and Reference Level Offset attributes.

ConfigureSweepCoupling()
  This function configures the coupling and sweeping attributes such as sweep time (time it takes to go from the start frequency to the stop frequency), Resolution Bandwidthm, and the Video Bandwidth. 
      
ConfigureTraceType()
   This function configures the Trace Type attribute such as Video Average, Minimum Hold, Clear Write, etc. 
   
FetchYTrace()
   This function returns the trace the spectrum analyzer acquires. The trace is from a previously initiated acquisition. The user calls the Initiate function to start an acquisition. The user calls the Acquisition Status function to determine when the acquisition is complete. 

   The user may call the Read Y Trace function instead of the Initiate function. This function starts an acquisition, waits for the acquisition to complete, and returns the trace in one function call. 

   The Amplitude array returns data that represents the amplitude of the signals obtained by sweeping from the start frequency to the stop frequency (in frequency domain, in the time domain the amplitude array is ordered from beginning of sweep to end). The Amplitude Units attribute determines the units of the points in the Amplitude array.

   This function does not check the instrument status. The user should call the AcquisitionStatus function at the conclusion of the sequence to check the instrument status. 
   
GetTraceName()
    This function returns the specific driver defined trace name that corresponds to the index that the user specifies. If the driver defines a qualified trace name, this property returns the qualified name. If the value that the user passes for the Index parameter is less than one or greater than the value of the Trace Count attribute, the function returns an empty string in the Name parameter and returns the Invalid Value error.

Initialize()
    This function opens a reference to the Spectrum Analyzer and sets the connected boolean to true.     

Initiate()
    This function initiates an acquisition. After calling this function, the spectrum analyzer leaves the idle state. This function does not check the instrument status. The user should call the Acquisition Status function to determine when the acquisition is complete.
   
ReadYTrace()
   This function initiates a signal acquisition based on the present instrument configuration. It then waits for the acquisition to complete, and returns the trace as an array of amplitude values. The amplitude array returns data that represent the amplitude of the signals obtained by sweeping from the start frequency to the stop frequency (in frequency domain, in time domain the amplitude array is ordered from beginning of sweep to end). The Amplitude Units attribute determines the units of the points in the amplitude array. This function resets the sweep count.

   If the spectrum analyzer did not complete the acquisition within the time period the user specified with the MaxTime parameter, the function returns the Max Time Exceeded error.

SelfTest()
   This VI runs the instrument's self test routine and returns the test result(s). 
   

Trigger Extension Group    
~~~~~~~~~~~~~~~~~~~~~~~~~~~

|image2|

Figure \: SpecAnBaseClass Trigger Properties UML Specification

Properties
~~~~~~~~~~

Trigger \: Struct
 A structure containing the properties of each module's trigger.  
	
	
	TriggerSource \: String
	  Specifies the source and type of the trigger signal that cause the analyzer to begin acquiring data. Examples are External, Immediate, Software, AC Line, etc.  
  
	TriggerLevel \: Double
	  Specifies the level that the signal shall reach to trigger the acqusition. The units are specified by the Amplitude Units attribute.  
	  
	TriggerSlope \: Enum
	  Specifies which slope of the trigger signal (Positive or Negative) triggers the acquisition.   
	 
Methods
~~~~~~~
ConfigureTrigger ()
	This function allows the user to configure the Spectrum Analyser to acquire measurements based on a software, external, video or etc signal and the associated paramater such as level and slope.
	
SendSoftwareTrigger ()
	This function sends a software trigger to the Spectrum Analyzer in order to begin acquisition. 

Utility Extension Group    
~~~~~~~~~~~~~~~~~~~~~~~~~~~

|image4|

Figure \: SpecAnBaseClass Utility Methods UML Specification

Methods
~~~~~~~
Reset ()
	This VI resets the instrument to a known state and sends initialization commands to the instrument.  The initialization commands set instrument settings such as Headers Off, Short Command form, and Data Transfer Binary to the state necessary for the operation of the instrument driver.
	
Disable ()
	This VI places the instrument in a quiescent state where it has minimal or no impact on the system to which it is connected.

Selftest ()
	This VI runs the instrument's self test routine and returns the test result(s). 

Marker Extension Group    
~~~~~~~~~~~~~~~~~~~~~~~~~~~

|image5|

Figure \: SpecAnBaseClass Properties and Methods UML Specification

Properties
~~~~~~~~~~

Marker \: Struct
 A structure containing the properties of each module's markers.  
	
	ActiveMarker \: [String]
	Specifies the marker which is currently active. The values for this attribute correspond to the Marker repeated capability. If the driver defines a qualified Marker name, this attribute returns the qualified name.
 
	MarkerEnabled \: Boolean
	If set to True , the active marker is enabled. When False, the active marker is disabled.   

	MarkerFrequencyCounterEnabled \: Boolean
	Enables/disables the marker frequency counter for greater marker measurement accuracy. If set to True, the marker frequency counter is enabled. If set to False, the marker frequency counter is disabled. This attribute returns the Marker Not Enabled error if the Marker Enabled attribute is set to False.  
	
	MarkerFrequencyCounterResolution \: Double
	Specifies the resolution of the frequency counter in Hertz. The measurement gate time is the reciprocal of the specified resolution.	
	
	MarkerPosition \: Double
	Specifies the frequency in Hertz or time position in seconds of the active marker (depending on the mode in which the analyzer is operating, frequency or time-domain). This attribute returns the Marker Not Enabled error if the active marker is not enabled.  
  
	MarkerThreshold \: Double
	Specifies the lower limit of the search domain vertical range for the Marker Search function.
	
	MarkerTrace \: String
	Specifies the Trace for the active marker.
	
	PeakExcursion \: Double
	Specifies the minimum amplitude variation of the signal in dB that the Marker Search function can identify as a peak.
	
	SignalTrackEnabled \: Double
	Specifies the lower limit of the search domain vertical range for the Marker Search function.


Methods
~~~~~~~

ConfigureMarkerEnabled ()
	This function enables the active marker on the specified Trace.

ConfigureMarkerFrequencyCounter ()
	This function sets the marker frequency counter resolution and enables or disables the marker frequency counter.

ConfigureMarkerSearch ()
	This function configures the Peak Excursion and Marker Threshold attribute values

ConfigureSignalTrackEnabled ()
	If set to True , the active marker is enabled. When False, the active marker is disabled. For additional information about signal-tracking, see Section 1.4, Definition of Terms and Acronyms, and Section 6.2.12, Signal Track Enabled.

DisableAllMarkers ()
	This function turns off all markers.

GetMarkerName ()
	This function returns the specific driver defined marker name that corresponds to the index that the user specifies. If the driver defines a qualified marker name, this function returns the qualified name. If the value that the user passes for the Index parameter is less then one or greater than the value of the Marker Count attribute, the function returns an empty string in the Name parameter and returns the Invalid Value error

MarkerSearch ()
	This function specifies the type of marker search and performs the search. This function returns the Marker Not Enabled error if the Marker Enabled attribute is set to False.

MoveMarker ()
	This function specifies the frequency in Hertz or time position in seconds of the specified horizontal position.

QueryMarker ()
	This function returns the horizontal position and the amplitude level of the active marker.
	
SetActiveMarker ()
	This function selects one of the available markers, and makes it the active marker.

SetInstrumentFromMarker()
	This function uses the Marker Position or Marker Amplitude attributes to configure the spectrum analyzer setting specified by the InstrumentSetting parameter. This function may set the Frequency Start, Frequency Stop, or Reference Level attributes. If the Marker Enabled attribute is set to False, this function returns the Marker Not Enabled error. If the Marker Type attribute is not Delta and the InstrumentSetting parameter is Frequency Span, the function returns the Delta Marker Not Enabled error.


Keysight44xxClass
+++++++++++++++++

The Keysight44xx inherits the all the properties and methods from the SpecAnBase class and includes additional trigger properties.  

|image3|

Figure \: Keysight44xxClass Properties UML Specification

Properties
~~~~~~~~~~

RFBurst \: Struct
 A structure containing the properties of an RFBurst Trigger.  
	
	
	TriggerLevelType \: Enum
	Specifies the frequency in Hertz or time position in seconds of the active marker (depending on the mode in which the analyzer is operating, frequency or time-domain). This attribute returns the Marker Not Enabled error if the active marker is not enabled.  
  
	FrequencySelect \: Boolean
	Returns the amplitude of the active marker. The units are specified by the Amplitude Units attribute, except when the Marker Type attribute is set to Delta. Then the units are dB. If the Marker Enabled attribute is set to False, any attempt to read this attribute returns the Marker Not Enabled error.
  	  
	NarrowPulseDiscriminator \: Boolean
	If set to True , the active marker is enabled. When False, the active marker is disabled. 

TV \: Struct
 A structure containing the properties of a TV Trigger.  
	
	MonitorEnabled \: Boolean
	Specifies the frequency in Hertz or time position in seconds of the active marker (depending on the mode in which the analyzer is operating, frequency or time-domain). This attribute returns the Marker Not Enabled error if the active marker is not enabled.  
  
	TVField \: Enum
	Returns the amplitude of the active marker. The units are specified by the Amplitude Units attribute, except when the Marker Type attribute is set to Delta. Then the units are dB. If the Marker Enabled attribute is set to False, any attempt to read this attribute returns the Marker Not Enabled error.
  	  
	TriggerSource \: Enum
	If set to True , the active marker is enabled. When False, the active marker is disabled.   
	
	TVSignalFormat \: Enum
	Specifies the frequency in Hertz or time position in seconds of the active marker (depending on the mode in which the analyzer is operating, frequency or time-domain). This attribute returns the Marker Not Enabled error if the active marker is not enabled.  
  
	SynchronizeSweep \: Boolean
	Returns the amplitude of the active marker. The units are specified by the Amplitude Units attribute, except when the Marker Type attribute is set to Delta. Then the units are dB. If the Marker Enabled attribute is set to False, any attempt to read this attribute returns the Marker Not Enabled error.
  	  
	SynchronizationLineNumber \: Int32
	If set to True , the active marker is enabled. When False, the active marker is disabled. 	 

No new methods were added to this plugin at this time. 


.. |image0| image:: images/SpecAn/image0.png
   :width: 3in
   
.. |image1| image:: images/SpecAn/image1.png
   :width: 3in
   
.. |image2| image:: images/SpecAn/image2.png
   :width: 3in
   
.. |image3| image:: images/SpecAn/image3.png
   :width: 3in
   
.. |image4| image:: images/SpecAn/image4.png
   :width: 3in
   
.. |image5| image:: images/SpecAn/image5.png
   :width: 3in