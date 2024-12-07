package = "day1"
version = "dev-1"
source = {
	url = "*** please add URL for source tarball, zip or repository here ***",
}

dependencies = {
	--"lua >= 5.1",
	"inspect >= 3.0", -- Add the package you installed
	"penlight",
}

description = {
	homepage = "*** please enter a project homepage ***",
	license = "*** please specify a license ***",
}
build = {
	type = "builtin",
	modules = {
		day1 = "day1.lua",
	},
}
