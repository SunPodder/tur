TERMUX_PKG_HOMEPAGE=https://github.com/castwide/solargraph
TERMUX_PKG_DESCRIPTION="A Ruby language server"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@SunPodder"
TERMUX_PKG_VERSION=0.50.0
TERMUX_PKG_DEPENDS="ruby"
TERMUX_PKG_SKIP_SRC_EXTRACT=true
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_PLATFORM_INDEPENDENT=true
_GEM_DEPENDENCIES="backport benchmark diff-lcs bundler e2mmap jaro_winkler kramdown kramdown-parser-gfm parser rbs reverse_markdown rubocop thor tilt yard"

termux_step_pre_configure() {
	ruby_version=$(. $TERMUX_SCRIPTDIR/packages/ruby/build.sh; echo $TERMUX_PKG_VERSION)
}

termux_step_make_install() {
	local gemdir="$TERMUX_PREFIX/lib/ruby/gems/${ruby_version:0:3}.0"

	rm -rf "$gemdir/solargraph-$TERMUX_PKG_VERSION"
	rm -rf "$gemdir/doc/solargraph-$TERMUX_PKG_VERSION"

	gem install --ignore-dependencies --no-user-install --verbose \
		-i "$gemdir" -n "$TERMUX_PREFIX/bin" solargraph -v "$TERMUX_PKG_VERSION"

	sed -i -E "1 s@^(#\!)(.*)@\1${TERMUX_PREFIX}/bin/ruby@" \
		"$TERMUX_PREFIX/bin/solargraph"
}

termux_step_install_license() {
	local gemdir="$TERMUX_PREFIX/lib/ruby/gems/${ruby_version:0:3}.0"
	mkdir -p $TERMUX_PREFIX/share/doc/$TERMUX_PKG_NAME
	cp $gemdir/gems/solargraph-${TERMUX_PKG_VERSION}/LICENSE \
		$TERMUX_PREFIX/share/doc/$TERMUX_PKG_NAME/
}

termux_create_debscripts() {
	cat <<- EOF > ./postinst
	#!$TERMUX_PREFIX/bin/sh
	echo "Installing solargraph dependencies"
	gem install $_GEM_DEPENDENCIES --platform=ruby -- --use-system-libraries
	exit 0
	EOF
}

