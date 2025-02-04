# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python{3_5,3_6} )

inherit distutils-r1 git-r3

DESCRIPTION="Small Animal Magnetic Resonance Imaging"
HOMEPAGE="https://github.com/IBT-FMI/SAMRI"
SRC_URI=""
EGIT_REPO_URI="https://github.com/IBT-FMI/SAMRI"

LICENSE="GPL-3"
SLOT="0"
IUSE="test"
KEYWORDS=""

DEPEND="
	test? (
		dev-python/pytest[${PYTHON_USEDEP}]
		sci-biology/samri_bidsdata
		sci-biology/samri_bindata
		)
"
RDEPEND="
	dev-python/argh[${PYTHON_USEDEP}]
	dev-python/joblib[${PYTHON_USEDEP}]
	>=dev-python/matplotlib-2.0.2[${PYTHON_USEDEP}]
	>=dev-python/numpy-1.13.3[${PYTHON_USEDEP}]
	dev-python/pandas[${PYTHON_USEDEP}]
	dev-python/seaborn[${PYTHON_USEDEP}]
	dev-python/statsmodels[${PYTHON_USEDEP}]
	media-gfx/blender
	>=sci-biology/fsl-5.0.9
	sci-biology/bru2nii
	sci-biology/mouse-brain-atlases
	sci-libs/nibabel[${PYTHON_USEDEP}]
	>=sci-libs/nipy-0.4.1[${PYTHON_USEDEP}]
	>=sci-libs/nipype-0.14.0_pre20170830[${PYTHON_USEDEP}]
	<=sci-libs/pybids-0.6.5[${PYTHON_USEDEP}]
	sci-libs/scikits_image[${PYTHON_USEDEP}]
	sci-libs/scipy[${PYTHON_USEDEP}]
	sci-biology/ants
	sci-biology/afni
	sci-biology/nilearn[${PYTHON_USEDEP}]
"

python_test() {
	distutils_install_for_testing
	export MPLBACKEND="agg"
	export PATH=${TEST_DIR}/scripts:$PATH
	export PYTHONIOENCODING=utf-8
	./test_scripts.sh || die "Test scripts failed."
	sed -i \
		-e '1s/^/import pytest \n/' \
		-e "/def test_bru2bids():/i@pytest.mark.skip('Skipped by Portage, as this was already tested in test_scripts.sh')" \
		samri/pipelines/tests/test_reposit.py || die
	cd "${BUILD_DIR}" || die
	pytest -vv || die
}
