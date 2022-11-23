












Ndef(\t, {|freq=440 index=1 amp phaseFreqMod=1 phaseIndex=1|

	var mod = SinOsc.ar(freq, 0, index);
	var sig = SinOsc.ar(freq * mod, SinOsc.kr(phaseFreqMod, 0, phaseIndex) );

	Out.ar(0, sig!2 ); }).play;








OSCdef(\abs_x, {|msg, time, addr, recvPort|
	Ndef(\t).set(\freq, msg[1]+100);

}, '/abs_x', nil);


OSCdef(\abs_y, {|msg, time, addr, recvPort| Ndef(\t).set(\index, msg[1]+50);  }, '/abs_y', nil);



OSCdef(\abs_rz, {|msg, time, addr, recvPort| Ndef(\t).set(\phaseFreqMod, msg[1]);     }, '/abs_rz', nil);


OSCdef(\abs_throttle, {|msg, time, addr, recvPort| Ndef(\t).set(\phaseIndex, msg[1]); }, '/abs_throttle', nil);






