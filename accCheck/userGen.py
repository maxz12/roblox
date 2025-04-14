import itertools
import argparse
import os


def parse_arguments():
    parser = argparse.ArgumentParser(
        description="Generate customizable username combinations based on provided settings."
    )
    parser.add_argument(
        "--length",
        type=int,
        default=3,
        help="Length of the username. Default is 4."
    )
    parser.add_argument(
        "--allowed-first",
        type=str,
        default="abcdefghijklmnopqrstuvwxyz0123456789",
        help="Allowed characters for the first position. Default is lowercase letters and digits."
    )
    parser.add_argument(
        "--allowed-middle",
        type=str,
        default="abcdefghijklmnopqrstuvwxyz0123456789_",
        help="Allowed characters for middle positions (if any). Default includes lowercase letters, digits, and underscore."
    )
    parser.add_argument(
        "--allowed-last",
        type=str,
        default="abcdefghijklmnopqrstuvwxyz0123456789",
        help="Allowed characters for the last position. Default is lowercase letters and digits."
    )
    parser.add_argument(
        "--output",
        type=str,
        default="usernames.txt",
        help="Output filename where usernames will be saved. Default is usernames.txt."
    )
    return parser.parse_args()


def generate_usernames(length, first_chars, middle_chars, last_chars):
    # If length is 1, only the first position applies.
    if length < 1:
        raise ValueError("The length of the username must be at least 1.")

    # Build a list where each element represents allowed characters for that index.
    pattern = []
    if length == 1:
        pattern = [first_chars]
    else:
        pattern.append(first_chars)
        if length > 2:
            # For positions 2 to (n-1), use middle allowed characters.
            pattern.extend([middle_chars] * (length - 2))
        pattern.append(last_chars)

    # Calculate total combinations (careful, for large length this number can be enormous)
    total = 1
    for p in pattern:
        total *= len(p)
    print(f"Generating {total} username combinations...")

    # Use itertools.product to generate all possible combinations.
    for combo in itertools.product(*pattern):
        yield "".join(combo)


def main():
    args = parse_arguments()
    output_path = args.output

    # Ensure output directory exists
    os.makedirs(os.path.dirname(os.path.abspath(output_path)), exist_ok=True)

    count = 0
    with open(output_path, "w") as file:
        for username in generate_usernames(args.length, args.allowed_first, args.allowed_middle, args.allowed_last):
            file.write(username + "\n")
            count += 1

    print(f"Saved {count} usernames to {output_path}")


if __name__ == "__main__":
    main()