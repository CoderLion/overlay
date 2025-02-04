# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python2_7 python3_{4,5,6} )

inherit distutils-r1 eutils virtualx

MYPN="${PN/scikits_/scikit-}"
MYP="${MYPN}-${PV}"

DESCRIPTION="Image processing routines for SciPy"
HOMEPAGE="https://scikit-image.org/"
SRC_URI="mirror://pypi/${PN:0:1}/${MYPN}/${MYP}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux"
IUSE="doc freeimage pyamg test"

RDEPEND="
	dev-python/cloudpickle[${PYTHON_USEDEP}]
	dev-python/dask[${PYTHON_USEDEP}]
	dev-python/matplotlib[${PYTHON_USEDEP}]
	dev-python/networkx[${PYTHON_USEDEP}]
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-python/pillow[${PYTHON_USEDEP}]
	dev-python/pywavelets[${PYTHON_USEDEP}]
	dev-python/six[${PYTHON_USEDEP}]
	sci-libs/scipy[sparse,${PYTHON_USEDEP}]
	freeimage? ( media-libs/freeimage )
	pyamg? ( dev-python/pyamg[${PYTHON_USEDEP}] )"
DEPEND="${RDEPEND}
	>=dev-python/cython-0.23[${PYTHON_USEDEP}]
	dev-python/setuptools[${PYTHON_USEDEP}]
	test? (	dev-python/nose[${PYTHON_USEDEP}] )"

S="${WORKDIR}/${MYP}"

DOCS=( CONTRIBUTORS.txt RELEASE.txt TODO.txt )

# Fails on Gentoo
#RESTRICT="test"

python_prepare_all() {
	# Remove pip dependency
	sed -i '1iimport os.path as osp'\
		skimage/__init__.py\
		skimage/data/__init__.py\
		|| die
	distutils-r1_python_prepare_all
}

python_test() {
	distutils_install_for_testing
	#cd "${TEST_DIR}" || die "no ${TEST_DIR} available"
	echo "backend : Agg" > matplotlibrc || die
	#echo "backend.qt4 : PyQt4" >> matplotlibrc || die
	#echo "backend.qt4 : PySide" >> matplotlibrc || die
	mkdir "${WORKDIR}/empty_test_dir" || die
	cd "${WORKDIR}/empty_test_dir" || die
	pytest --pyargs skimage || die
	#pytest -vv || die
}

pkg_postinst() {
	optfeature "FITS io capability" dev-python/astropy
	optfeature "GTK" dev-python/pygtk
	# not in portage yet
	#optfeature "io plugin providing a wide variety of formats, including specialized formats using in medical imaging." dev-python/simpleitk
	#optfeature "io plugin providing most standard formats" dev-python/imread
}
