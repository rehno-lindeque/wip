{
  mkShell,
  python,
  black,
  mypy,
  flake8,
}:
mkShell {
  buildInputs = [
    # Python
    python
    # python code formatting
    black
    # python type checking
    mypy
    # python style guide enforcement
    flake8
  ];
}
