@echo (set_color blue)(status filename)(set_color normal)

@test "failing test" (
    false; echo $status
) -eq 0

@test "failing test" (
    echo "foo"
) = "bar"