TERMUX_PKG_HOMEPAGE=https://github.com/surrealdb/surrealdb
TERMUX_PKG_DESCRIPTION="A scalable, distributed, collaborative, document-graph database, for the realtime web"
TERMUX_PKG_LICENSE="non-free"
TERMUX_PKG_LICENSE_FILE="LICENSE"
TERMUX_PKG_MAINTAINER="@SunPodder"
TERMUX_PKG_VERSION="1.3.0"
TERMUX_PKG_SRCURL="https://github.com/surrealdb/surrealdb/archive/refs/tags/v${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=75eca5445821071efa12a3d20153f21c3b26bff73b11676538e6171f52cab9b1
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_BUILD_DEPENDS="openssl, zlib"
TERMUX_PKG_BLACKLISTED_ARCHES="arm, i686"

termux_step_configure() {
	env -i PATH="$PATH" sudo apt update
	env -i PATH="$PATH" sudo apt install protobuf-compiler -y

    termux_setup_rust
    export CARGO_HOME="${HOME}/.cargo"
    cargo fetch --target $CARGO_TARGET_NAME

    rm -rf $CARGO_HOME/registry/src/index.crates.io-*/librocksdb-sys-0.11.0*/
    rm -rf $CARGO_HOME/registry/src/index.crates.io-*/jemalloc-sys*/
    cargo fetch --target $CARGO_TARGET_NAME

    sed -e "s|@TERMUX_PREFIX@|$TERMUX_PREFIX|" \
        $TERMUX_PKG_BUILDER_DIR/librocksdb-sys.diff \
	    | patch --silent -p1 \
            -d $CARGO_HOME/registry/src/index.crates.io-*/librocksdb-sys-0.11.0*/rocksdb

    cat $TERMUX_PKG_BUILDER_DIR/jemalloc-sys.diff \
        | patch --silent -p1 \
            -d $CARGO_HOME/registry/src/index.crates.io-*/jemalloc-sys-*/
}

termux_step_make() {
    export CXXFLAGS+=" -lz"
	cargo build --jobs $TERMUX_MAKE_PROCESSES --target $CARGO_TARGET_NAME --release
}

termux_step_make_install() {
	install -Dm755 -t $TERMUX_PREFIX/bin target/${CARGO_TARGET_NAME}/release/surreal
}

