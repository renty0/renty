import subprocess

def run_build():
    result = subprocess.run(['dotnet', 'build'], cwd=r'E:\Courses\Work\renty\Client\API\Application', capture_output=True, text=True)
    with open('build_output_python.txt', 'w') as f:
        f.write("STDOUT:\n")
        f.write(result.stdout)
        f.write("\nSTDERR:\n")
        f.write(result.stderr)
    print("Build output saved to build_output_python.txt")

if __name__ == "__main__":
    run_build()
