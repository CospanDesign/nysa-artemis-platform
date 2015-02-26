#! /usr/bin/python
# Copyright (c) 2013 Dave McCoy (dave.mccoy@cospandesign.com)

# This file is part of Nysa (wiki.cospandesign.com/index.php?title=Nysa).
#
# Nysa is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# any later version.
#
# Nysa is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Nysa; If not, see <http://www.gnu.org/licenses/>.

""" artemis

Concrete interface for Nysa on the Artemis platform
"""

__author__ = 'dave.mccoy@cospandesign.com (Dave McCoy)'

""" Changelog:
10/18/2013
    -Pep8ing the module and some cleanup
09/21/2012
    -added core dump function to retrieve the state of the master when a crash
    occurs
08/30/2012
    -Initial Commit
"""
import sys
import os
import Queue
import threading
import time
import gc
from array import array as Array

p = os.path.join(os.path.dirname(__file__), os.pardir)
sys.path.append(os.path.join(os.path.dirname(__file__),
                             os.pardir))

from nysa.host.nysa import Nysa
from nysa.common import status
from nysa.host.nysa import NysaCommError

INTERRUPT_COUNT = 32

#50 mS sleep between interrupt checks
INTERRUPT_SLEEP = 0.050

ARTEMIS_RESET = 1
ARTEMIS_WRITE = 2
ARTEMIS_READ = 3
ARTEMIS_PING = 4
ARTEMIS_DUMP_CORE = 5

ARTEMIS_RESP_OK = 0
ARTEMIS_RESP_ERR = -1

_artemis_instances = {}

def Artemis(idVendor = 0x0403, idProduct = 0x8531, sernum = None, status = False):
    global _artemis_instances
    if sernum in _artemis_instances:
        return _artemis_instances[sernum]
    _artemis_instances[sernum] = _Artemis(idVendor, idProduct, sernum, status)
    return _artemis_instances[sernum]

class _Artemis (Nysa):
    """
    Artemis

    Concrete Class that implemented Artemis specific communication functions
    """

    def __init__(self, sernum = None, status = False):
        Nysa.__init__(self, status)
        self.sernum = sernum

        self.reset()

    def __del__(self):
        pass

    def _open_dev(self):
        pass

    def read(self, address, length = 1, disable_auto_inc = False):
        """read

        read data from Artemis

        Args:
            address (long): Address of the register/memory to read
            length (int): Number of 32-bit words to read
            disable_auto_inc (bool): if true, auto increment feature will be
                disabled

        Returns:
            (Byte Array): A byte array containing the raw data returned from
            Artemis

        Raises:
            NysaCommError
        """
        raise AssertionError("%s should be implemented by concrete interface class" % sys._getframe().f_code.co_name, self.s)
        return None

    def write(self, address, data, disable_auto_inc = False):
        """write

        Write data to a Nysa image

        Args:
            address (long): Address of the register/memory to write to
            memory_device (boolean):
                True: Memory device
                False: Peripheral device
            data (array of bytes): Array of raw bytes to send to the devcie
            disable_auto_inc (boolean): Default False
                Set to true if only writing to one memory address (FIFO Mode)

        Returns: Nothing

        Raises:
            NysaCommError
        """
        raise AssertionError("%s should be implemented by concrete interface class" % sys._getframe().f_code.co_name, self.s)

    def ping (self):
        """ping

        Args:
            Nothing

        Returns:
            Nothing

        Raises:
            NysaCommError
        """
        raise AssertionError("%s should be implemented by concrete interface class" % sys._getframe().f_code.co_name, self.s)

    def reset (self):
        """ reset

        Software reset the Nysa FPGA Master, this may not actually reset the entire
        FPGA image

        Args:
            Nothing

        Return:
            Nothing

        Raises:
            NysaCommError: Failue in communication
        """
        raise AssertionError("%s should be implemented by concrete interface class" % sys._getframe().f_code.co_name, self.s)

    def dump_core(self):
        """ dump_core

        Returns the state of the wishbone master priorto a reset, this is usefu for
        statusging a crash

        Command Format

        ID 0F 00 00 00 00 00 00 00
            ID: ID Byte (0xCD)
            0F: Dump Core Command
            00 00 00 00 00 00 00 00 00 00 00: Zeros

        Args:
            Nothing

        Returns:
            (Array of 32-bit Values) to be parsed by the core_analyzer utility

        Raises:
            NysaCommError: A failure in communication is detected
        """
        raise AssertionError("%s should be implemented by concrete interface class" % sys._getframe().f_code.co_name, self.s)

    def register_interrupt_callback(self, index, callback):
        """ register_interrupt

        Setup the thread to call the callback when an interrupt is detected

        Args:
            index (Integer): bit position of the device
                if the device is 1, then set index = 1
            callback: a function to call when an interrupt is detected

        Returns:
            Nothing

        Raises:
            Nothing
        """
        raise AssertionError("%s should be implemented by concrete interface class" % sys._getframe().f_code.co_name, self.s)

    def unregister_interrupt_callback(self, index, callback = None):
        """ unregister_interrupt_callback

        Removes an interrupt callback from the reader thread list

        Args:
            index (Integer): bit position of the associated device
                EX: if the device that will receive callbacks is 1, index = 1
            callback: a function to remove from the callback list

        Returns:
            Nothing

        Raises:
            Nothing (This function fails quietly if ther callback is not found)
        """
        raise AssertionError("%s should be implemented by concrete interface class" % sys._getframe().f_code.co_name, self.s)

    def wait_for_interrupts(self, wait_time = 1, dev_id = None):
        """ wait_for_interrupts

        listen for interrupts for the user specified amount of time

        The Nysa image will send a small packet of info to the host when a slave
        needs to send information to the host

        Response Format:
            ??


        Args:
            wait_time (Integer): the amount of time in seconds to wait for an
                interrupt
            dev_id (Integer): Optional device id, if set the function will look
                if an interrupt has already been declared for that function, if
                so then return immediately otherwise setup a callback for this


        Returns (boolean):
            True: Interrupts were detected
            Falses: Interrupts were not detected

        Raises:
            NysaCommError: A failure in communication is detected
        """
        raise AssertionError("%s should be implemented by concrete interface class" % sys._getframe().f_code.co_name, self.s)
        return False

    def get_board_name(self):
        return "Artemis"

    def upload(self, filepath):
        raise AssertionError("%s should be implemented by concrete interface class" % sys._getframe().f_code.co_name, self.s)

    def program (self):
        raise AssertionError("%s should be implemented by concrete interface class" % sys._getframe().f_code.co_name, self.s)

    def ioctl(self, name, arg = None):
        raise AssertionError("%s should be implemented by concrete interface class" % sys._getframe().f_code.co_name, self.s)

    def list_ioctl(self):
        raise AssertionError("%s should be implemented by concrete interface class" % sys._getframe().f_code.co_name, self.s)

    def get_sdb_base_address(self):
        raise AssertionError("%s should be implemented by concrete interface class" % sys._getframe().f_code.co_name, self.s)
