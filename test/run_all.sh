for f in check*
do
	echo "$f tests.."
	bash $f
	echo
done
