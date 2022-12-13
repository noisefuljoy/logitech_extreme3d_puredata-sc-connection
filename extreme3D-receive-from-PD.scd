

/*
Ndef(\t, {|freq=100 index=1 amp=0.25 phaseFreqMod=1 phaseIndex=1|

	var mod = SinOsc.ar(freq, 0, index);
	var sig = SinOsc.ar(freq * mod, SinOsc.kr(phaseFreqMod, 0, phaseIndex) );

	Out.ar(0, sig!2 ); });
*/



SynthDef(\extreme_fm, {|freqBus indexBus att=0.2 rel=0.3 amp=0.25 phaseFreqModBus phaseIndexBus gate=1|
	var freq = In.kr(freqBus, 1);
	var index = In.kr(indexBus, 1);
	var phaseFreqMod = In.kr(phaseFreqModBus, 1);
	var phaseIndex = In.kr(phaseIndexBus, 1);
	var mod = SinOsc.ar(freq, 0, index);
	var sig = SinOsc.ar(freq * mod, SinOsc.kr(phaseFreqMod, 0, phaseIndex) );
	var env = EnvGen.ar(Env.adsr(att, 0.0, 1, rel), gate, doneAction: 2);
	sig = sig * env;
	Out.ar(0, sig!2 ); }).add;

~extremeGroup = Group.new;
~extremeSwitch = 0;
~extremeBuses = Array.fill(4, { Bus.control(s, 1); });
~extremeBuses[0].set(100);
~extremeBuses[1].set(1);
~extremeBuses[2].set(1);
~extremeBuses[3].set(1);

~freqSpec = [50, 3000, 4,1].asSpec;
~indexSpec = [1, 500, \linear,0.1].asSpec;
~phaseFreqModSpec = [0.001, 80, \linear,0.1].asSpec;
~phaseIndexSpec = [1, 600, \linear,0.1].asSpec;

OSCdef(\btn_0, {|msg, time, addr, recvPort| msg.postln;

	if ( ~extremeSwitch == 0, {
		if ( msg[1] == 1, {
			Synth(\extreme_fm, [\freqBus, ~extremeBuses[0].index, \indexBus,~extremeBuses[1].index, \phaseFreqModBus, ~extremeBuses[2].index,\phaseIndexBus, ~extremeBuses[3].index ], ~extremeGroup );
			~extremeSwitch = 1; }); }, {
			if (msg[1] == 0, {
				~extremeGroup.set(\gate, 0);
				~extremeSwitch = 0;

	}); });



}, '/btn_0', nil);







OSCdef(\abs_x, {|msg, time, addr, recvPort| msg.postln;    ~extremeBuses[0].set(~freqSpec.map(msg[1]/1021); );     }, '/abs_x', nil);


OSCdef(\abs_y, {|msg, time, addr, recvPort| msg.postln; ~extremeBuses[1].set(~indexSpec.map(msg[1]/1021); );     }  , '/abs_y', nil);



OSCdef(\abs_rz, {|msg, time, addr, recvPort| msg.postln; ~extremeBuses[2].set(~phaseFreqModSpec.map(msg[1]/255); );   }, '/abs_rz', nil);


OSCdef(\abs_throttle, {|msg, time, addr, recvPort| msg.postln; ~extremeBuses[3].set(~phaseIndexSpec.map(msg[1]/255); );    }, '/abs_throttle', nil);














