from subprocess import PIPE, run


def verbose(val=False):
    """
    This function is to set the verbose in running R commands
    :param val:
    """
    global VERBOSE
    VERBOSE = val


def _getverbose():
    """
    private function
    :return:
    """
    return VERBOSE


def call_R_modules(command):
    """
    This function is used to call Rscripts in console and track the sysout, syserror
    Sysout is controlled by Verbose and syserror is pushed to display if the return code is greater than zero

    :return:
    :param command: A comma seperated list of R command and its arguments eg. sample.R arg1 --myarg arg2
    :return:
    """
    DEBUG = _getverbose()
    print("{}".format(command))
    result = run(command, stdout=PIPE, stderr=PIPE, universal_newlines=True)
    if DEBUG:
        print(
            " =================================== SYSOUT =================================== \n {} \n =========================================================================================== ".format(
                result.stdout))
        if result.returncode > 0:
            print(
                " =================================== ERROR =================================== \n {} \n ========================================================================================== ".format(
                    result.stderr))
    else:
        if result.returncode > 0:
            print(" === ERROR ===")
            for line in result.stderr.splitlines():
                if "Error" in line or "Calls" in line:
                    print("{}".format(line))

            print("==========================================================================================")

    return result.returncode
