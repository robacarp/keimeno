.PHONY: test
test:
	crystal run test/test_helper.cr test/**/*_test.cr -- --chaos

