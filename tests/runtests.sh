echo "Running unit tests:"

for i in tests/*_tests
do 
    if test -f $i
    then 
        # run ./test_bin_file, 2(stderr), >>(to a file)
        # valgrind is a debugging tool
        if $VALGRIND ./$i 2>> tests/tests.log
        then   
            echo $i PASS
        else 
            echo "Error in test $i: here's tests/tests.log"
            echo "------"
            tail tests/tests.log
            exit 1
        fi
    fi
done

echo ""