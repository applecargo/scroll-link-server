(
OSCdef(\osc_dispatcher,
	{ |msg|
		var target = msg[1];
		var value = msg[2]; //range: 0...5000
		msg.postln;
		//
		switch(target,
			\a, {
			},
			\b, {
			},
			\c, {
			},
			\d, {
			},
			\e, {
			},
			\f, {
			},
			\g, {
			},
			\h, {
			}
		);
	},'/scroll'
);
)

(
OSCdef(\osc_dispatcher_pd,
	{ |msg|
		var target = msg[1];
		var value = msg[2]; //range: 0...1.5
		msg.postln;
		//
		switch(target,
			\a, {
			},
			\b, {
			},
			\c, {
			},
			\d, {
			},
			\e, {
			},
			\f, {
			},
			\g, {
			},
			\h, {
			}
		);
	},'/puredata',recvPort:57030
);
)
