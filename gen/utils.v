module gen

import os

fn run(cmd string) ?string {
	res := os.execute_or_panic(cmd)
	if res.exit_code != 0 {
		return error('Command returned $res.exit_code exit code: $cmd')
	}
	return res.output
}
