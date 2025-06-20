import subprocess
import re

def modify_and_run(util_value):
    
    with open('run_invs.tcl', 'r') as file:
        content = file.read()
    
    new_content = re.sub(r'set util\s+\d+\.\d+', f'set util {util_value:.2f}', content)
    
    with open('run_invs.tcl', 'w') as file:
        file.write(new_content)
    
    subprocess.run(['innovus', '-init', 'run_invs.tcl'], check=True)

def main():
    
    util_values = [round(0.60 + i * 0.01, 2) for i in range(21)]
    
    for util in util_values:
        print(f"Running with util = {util:.2f}")
        modify_and_run(util)

if __name__ == "__main__":
    main()