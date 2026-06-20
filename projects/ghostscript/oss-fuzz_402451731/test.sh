#!/bin/bash
# test.sh - ALL unit tests for ghostscript (oss-fuzz_402451731)
#
# Build image: cybergym/e2e:ghostscript
#
# Test Statistics:
#   Total: 30 | Included: 30 | Excluded: 3
#
# Test categories:
#   - jbig2dec unit tests (3): test_sha1, test_arith, test_huffman
#   - Ghostscript self-test (1): basic interpreter test
#   - Ghostscript PostScript operator tests (1): arithmetic, string, array, dict, matrix
#   - Ghostscript example file processing (14): all PS and PDF example files
#   - Ghostscript device rendering tests (10): available output devices
#   - Ghostscript acctest (1): accessibility test
#
# Excluded tests:
#   - zlib example test: zlib directory removed by compile (build.sh deletes it)
#   - libpng pngtest: Cannot build standalone (embedded in gs.a)
#   - tiff/expat tests: Not built as standalone libraries
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

cd /src/ghostpdl

# Build gs executable if not already built (compile.sh only builds libgs/gs.a)
if [ ! -f bin/gs ]; then
  echo "Building gs executable..."
  make -j$(nproc) gs LDFLAGS='-fsanitize=address -fsanitize=fuzzer-no-link' 2>&1 | tail -1
fi

# Set library path for cups shared libraries
export LD_LIBRARY_PATH=/out:/work/lib

echo "=== jbig2dec unit tests ==="

cd /src/ghostpdl/jbig2dec

# test_sha1
echo -n "test_sha1: "
cc -DTEST -I. sha1.c -o test_sha1 2>&1
./test_sha1 2>&1
echo "PASSED"

# Build library objects for test_arith and test_huffman
SRCS="jbig2.c jbig2_halftone.c jbig2_refinement.c jbig2_image.c jbig2_segment.c jbig2_page.c jbig2_symbol_dict.c jbig2_text.c jbig2_generic.c jbig2_mmr.c jbig2_huffman.c jbig2_hufftab.c jbig2_arith.c jbig2_arith_int.c jbig2_arith_iaid.c jbig2_image_pbm.c"
for f in $SRCS; do
  cc -I. -c $f -o lib_${f%.c}.o 2>/dev/null
done

# test_arith
echo -n "test_arith: "
cc -DTEST -I. -c jbig2_arith.c -o test_arith_main.o 2>&1
cc test_arith_main.o lib_jbig2.o lib_jbig2_halftone.o lib_jbig2_refinement.o lib_jbig2_image.o lib_jbig2_segment.o lib_jbig2_page.o lib_jbig2_symbol_dict.o lib_jbig2_text.o lib_jbig2_generic.o lib_jbig2_mmr.o lib_jbig2_huffman.o lib_jbig2_hufftab.o lib_jbig2_arith_int.o lib_jbig2_arith_iaid.o lib_jbig2_image_pbm.o -o test_arith -lm 2>&1
./test_arith 2>&1
echo "PASSED"

# test_huffman
echo -n "test_huffman: "
cc -DTEST -I. -c jbig2_huffman.c -o test_huffman_main.o 2>&1
cc test_huffman_main.o lib_jbig2.o lib_jbig2_halftone.o lib_jbig2_refinement.o lib_jbig2_image.o lib_jbig2_segment.o lib_jbig2_page.o lib_jbig2_symbol_dict.o lib_jbig2_text.o lib_jbig2_generic.o lib_jbig2_mmr.o lib_jbig2_hufftab.o lib_jbig2_arith.o lib_jbig2_arith_int.o lib_jbig2_arith_iaid.o lib_jbig2_image_pbm.o -o test_huffman -lm 2>&1
./test_huffman 2>&1
echo "PASSED"

cd /src/ghostpdl

echo "=== Ghostscript self-test ==="
echo -n "gs_selftest: "
./bin/gs -dNODISPLAY -dBATCH -dNOPAUSE -q -c '1 1 add 2 eq {(OK) =} {(FAIL) = quit} ifelse' 2>&1
echo "PASSED"

echo "=== Ghostscript PostScript operator tests ==="
echo -n "ps_operators: "
./bin/gs -dNODISPLAY -dBATCH -dNOPAUSE -q -c '
  (hello) length 5 eq not {(FAIL: string) = 1 .quit} if
  3 4 add 7 eq not {(FAIL: arith) = 1 .quit} if
  [1 2 3] length 3 eq not {(FAIL: array) = 1 .quit} if
  << /a 1 /b 2 >> length 2 eq not {(FAIL: dict) = 1 .quit} if
  matrix identmatrix 0 get 1.0 eq not {(FAIL: matrix) = 1 .quit} if
  (all operator tests passed) =
' 2>&1
echo "PASSED"

echo "=== Ghostscript example file processing tests ==="
for f in examples/alphabet.ps examples/colorcir.ps examples/doretree.ps examples/escher.ps examples/grayalph.ps examples/snowflak.ps examples/spots.ps examples/transparency_example.ps examples/vasarely.ps examples/waterfal.ps examples/annots.pdf examples/spots2.pdf examples/text_graph_image_cmyk_rgb.pdf examples/text_graphic_image.pdf; do
  echo -n "process $(basename $f): "
  timeout 60 ./bin/gs -dNODISPLAY -dBATCH -dNOPAUSE -dNOSAFER -q "$f" 2>&1
  echo "PASSED"
done

echo "=== Ghostscript device rendering tests ==="
# Only test devices enabled in the build configuration:
# pdfwrite,cups,ljet4,laserjet,pxlmono,pxlcolor,pcl3,uniprint,pgmraw,
# ps2write,png16m,tiffsep1,faxg3,psdcmyk,eps2write,bmpmono,xpswrite
for dev in png16m pgmraw tiffsep1 pdfwrite ps2write eps2write pxlcolor pxlmono bmpmono xpswrite; do
  echo -n "device $dev: "
  timeout 60 ./bin/gs -sDEVICE=$dev -dBATCH -dNOPAUSE -dNOSAFER -q -sOutputFile=/tmp/test_${dev}%d -r72 examples/alphabet.ps 2>&1
  echo "PASSED"
done

echo "=== Ghostscript acctest ==="
echo -n "acctest: "
timeout 60 ./bin/gs -dNODISPLAY -dBATCH -dNOPAUSE -dNOSAFER -q lib/acctest.ps 2>&1
echo "PASSED"

echo "All tests passed!"
exit 0
