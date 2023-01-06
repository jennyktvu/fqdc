def process(x, y):
    if x < 0:
        raise ValueError
    return x + y + 2


if __name__ == "__main__":
    z = process(3, 4)
    print(f"Result: {z}")
