hackup: *.hs Plugin/*.hs
	ghc --make -O2 Main.hs -o hackup

clean:
	-rm -f hackup *.hi *.o *~ Plugin/*~ Plugin/*.hi Plugin/*.o
