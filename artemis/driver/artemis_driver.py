#Distributed under the MIT licesnse.
#Copyright (c) 2015 Dave McCoy (dave.mccoy@cospandesign.com)

#Permission is hereby granted, free of charge, to any person obtaining a copy of
#this software and associated documentation files (the "Software"), to deal in
#the Software without restriction, including without limitation the rights to
#use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
#of the Software, and to permit persons to whom the Software is furnished to do
#so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in all
#copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#SOFTWARE.

""" DMA

Facilitates communication with the DMA controller

"""

__author__ = 'dave.mccoy@cospandesign.com (Dave McCoy)'

import sys
import os
import time

from array import array as Array


from nysa.host.driver import driver


ARTEMIS_ID          =   0x02

#Register Constants
CONTROL             =   0x00
STATUS              =   0x01

CONTROL                 = 00000000
BIT_CALIBRATION_DONE    = 0
BIT_DDR3_RST            = 1
BIT_P0_ENABLE           = 2
BIT_P1_ENABLE           = 3
BIT_P2_ENABLE           = 4
BIT_P3_ENABLE           = 5
BIT_P4_ENABLE           = 6
BIT_P5_ENABLE           = 7
BIT_PLL_LOCKED          = 8

DDR3_STATUS0            = 0000000

BIT_P0_RD_FULL          = 0
BIT_P0_RD_EMPTY         = 1
BIT_P0_RD_OVERFLOW      = 2
BIT_P0_RD_ERROR         = 3
BIT_P0_WR_EMPTY         = 4
BIT_P0_WR_FULL          = 5
BIT_P0_WR_UNDERRUN      = 6

BIT_P1_RD_FULL          = 0 + 8
BIT_P1_RD_EMPTY         = 1 + 8
BIT_P1_RD_OVERFLOW      = 2 + 8
BIT_P1_RD_ERROR         = 3 + 8
BIT_P1_WR_EMPTY         = 4 + 8
BIT_P1_WR_FULL          = 5 + 8
BIT_P1_WR_UNDERRUN      = 6 + 8

BIT_P2_RD_FULL          = 0 + 16
BIT_P2_RD_EMPTY         = 1 + 16
BIT_P2_RD_OVERFLOW      = 2 + 16
BIT_P2_RD_ERROR         = 3 + 16
BIT_P2_WR_EMPTY         = 4 + 16
BIT_P2_WR_FULL          = 5 + 16
BIT_P2_WR_UNDERRUN      = 6 + 16

BIT_P3_RD_FULL          = 0 + 24
BIT_P3_RD_EMPTY         = 1 + 24
BIT_P3_RD_OVERFLOW      = 2 + 24
BIT_P3_RD_ERROR         = 3 + 24
BIT_P3_WR_EMPTY         = 4 + 24
BIT_P3_WR_FULL          = 5 + 24
BIT_P3_WR_UNDERRUN      = 6 + 24

DDR3_STATUS1            = 00000002

BIT_P4_RD_FULL          = 0
BIT_P4_RD_EMPTY         = 1
BIT_P4_RD_OVERFLOW      = 2
BIT_P4_RD_ERROR         = 3
BIT_P4_WR_EMPTY         = 4
BIT_P4_WR_FULL          = 5
BIT_P4_WR_UNDERRUN      = 6

BIT_P5_RD_FULL          = 0 + 8
BIT_P5_RD_EMPTY         = 1 + 8
BIT_P5_RD_OVERFLOW      = 2 + 8
BIT_P5_RD_ERROR         = 3 + 8
BIT_P5_WR_EMPTY         = 4 + 8
BIT_P5_WR_FULL          = 5 + 8
BIT_P5_WR_UNDERRUN      = 6 + 8




class ArtemisDriverError(Exception):
    pass


class ArtemisDriver(driver.Driver):
    """
    Artemis Driver
    """
    @staticmethod
    def get_abi_class():
        return 0

    @staticmethod
    def get_abi_major():
        return driver.get_device_id_from_name("platform")

    @staticmethod
    def get_abi_minor():
        return ARTEMIS_ID


    def __init__(self, nysa, urn, debug = False):
        super (ArtemisDriver, self).__init__(nysa, urn, debug)

    def __del__(self):
        pass

    def is_ddr3_calibration_done(self):
        """
        Returns True if DDR3 Calibration is Done

        Args:
            Nothing

        Returns (Boolean):
            True: Calibration is done
            False: Calibration is not done
        Raises:
            Nothing
        """
        return self.is_register_bit_set(CONTROL, BIT_CALIBRATION_DONE)

    def is_main_pll_locked(self):
        """
        Returns True if the main PLL is locked

        Args:
            Nothing

        Returns (Boolean):
            True: PLL is Locked
            False: PLL is not locked

        Raises:
            Nothing
        """
        return self.is_register_bit_set(CONTROL, BIT_PLL_LOCKED)

    def is_ddr3_rst(self):
        """
        Returns true if DDR3 is in reset

        Args:
            Nothing

        Returns (Boolean):
            True: DDR3 Is in reset
            False: DDR3 is not in reset

        Raises:
            Nothing
        """
        return self.is_register_bit_set(CONTROL, BIT_DDR3_RST)

    def get_ddr3_channel_enable(self):
        """
        Returns a bit field of the status of the enabled DDR3 Channel
        You can feed the output into the static function
        static_is_ddr3_channel_enable(value)

        Args:
            Nothing

        Returns:
            Bitfield of the DDR3 channel enable stats
            Bit 0 [0x01] = P0 Enable (Wishbone DDR3 Channel)
            Bit 1 [0x02] = RW0 read/write channel
            Bit 2 [0x04] = W0 write only channel 0
            Bit 3 [0x08] = W1 write only channel 1
            Bit 4 [0x10] = R0 read only channel 0
            Bit 5 [0x20] = R1 read only channel 1

        Raises:
            Nothing
        """
        regs = self.read_register(CONTROL)
        regs = regs >> BIT_P0_ENABLE;
        return (regs & 0x3F)

    def get_ddr3_channel_status(self, channel):
        """
        Returns a channel status, the status is in the form of a
        bitfield. This bitfield can be fed into one of the 
        static_is_ddr3_[rd wr]_func which will return the enable
        for that particular bitfield. The idea is that you don't
        need to query the driver multiple times to find out if
        all the fields are set, you just need to query once then
        figure out what is set.

        Args:
            channel (integer): Channel to query

        Returns:
            Bitfield of the channel status
            Bit 0 [0x01] = read FIFO full
            Bit 1 [0x02] = read FIFO empty
            Bit 2 [0x04] = read FIFO overflow
            Bit 3 [0x08] = read FIFO error
            Bit 4 [0x10] = write FIFO empty
            Bit 5 [0x20] = write FIFO full
            Bit 6 [0x40] = write FIFO underrun
            
        Raises:
            Nothing
        """
        if channel < 4:
            regs = self.read_register(DDR3_STATUS1)
            regs >> (channel) * 8
            return (regs & 0x3F)
        else:
            regs = self.read_register(DDR3_STATUS1)
            regs >> (channel - 4) * 8
            return (regs & 0x3F)

    @staticmethod
    def static_is_ddr3_channel_rd_full(reg):
        """
        Using the status of the DDR3 from get_ddr3_channel_status
        this will return True if that channel read FIFO is full

        Args:
            reg (integer): DDR3 Channel Status from
                get_ddr3_channel_status

        Returns (Boolean):
            True: read FIFO is full
            False: read FIFO is not full

        Raises:
            Nothing
        """
        return (reg & (1 << BIT_P0_RD_FULL)) > 0

    @staticmethod
    def static_is_ddr3_channel_rd_empty(reg):
        """
        Using the status of the DDR3 from get_ddr3_channel_status
        this will return True if that channel read FIFO is empty

        Args:
            reg (integer): DDR3 Channel Status from
                get_ddr3_channel_status

        Returns (Boolean):
            True: read FIFO is empty
            False: read FIFO is not empty

        Raises:
            Nothing
        """

        return (reg & (1 << BIT_P0_RD_EMPTY)) > 0

    @staticmethod
    def static_is_ddr3_channel_rd_overflow(reg):
        """
        Using the status of the DDR3 from get_ddr3_channel_status
        this will return True if that channel read FIFO is overflow

        Args:
            reg (integer): DDR3 Channel Status from
                get_ddr3_channel_status

        Returns (Boolean):
            True: read FIFO is overflow
            False: read FIFO is not overflow

        Raises:
            Nothing
        """

        return (reg & (1 << BIT_P0_RD_OVERFLOW)) > 0

    @staticmethod
    def static_is_ddr3_channel_rd_error(reg):
        """
        Using the status of the DDR3 from get_ddr3_channel_status
        this will return True if that channel read FIFO is error

        Args:
            reg (integer): DDR3 Channel Status from
                get_ddr3_channel_status

        Returns (Boolean):
            True: read FIFO is error
            False: read FIFO is not error

        Raises:
            Nothing
        """

        return (reg & (1 << BIT_P0_RD_ERROR)) > 0

    @staticmethod
    def static_is_ddr3_channel_wr_empty(reg):
        """
        Using the status of the DDR3 from get_ddr3_channel_status
        this will return True if that channel write FIFO is empty

        Args:
            reg (integer): DDR3 Channel Status from
                get_ddr3_channel_status

        Returns (Boolean):
            True: write FIFO is empty
            False: write FIFO is not empty

        Raises:
            Nothing
        """
        return (reg & (1 << BIT_P0_WR_EMPTY)) > 0

    @staticmethod
    def static_is_ddr3_channel_wr_full(reg):
        """
        Using the status of the DDR3 from get_ddr3_channel_status
        this will return True if that channel write FIFO is full

        Args:
            reg (integer): DDR3 Channel Status from
                get_ddr3_channel_status

        Returns (Boolean):
            True: write FIFO is full
            False: write FIFO is not full

        Raises:
            Nothing
        """
        return (reg & (1 << BIT_P0_WR_FULL)) > 0

    @staticmethod
    def static_is_ddr3_channel_wr_underrun(reg):
        """
        Using the status of the DDR3 from get_ddr3_channel_status
        this will return True if that channel write FIFO is underrun

        Args:
            reg (integer): DDR3 Channel Status from
                get_ddr3_channel_status

        Returns (Boolean):
            True: write FIFO is underrun
            False: write FIFO is not underrun

        Raises:
            Nothing
        """
        return (reg & (1 << BIT_P0_WR_UNDERRUN)) > 0

    @staticmethod
    def static_is_ddr3_channel_enable(reg, channel):
        """
        Using the output of get_ddr3_channel_enable this function will return
        True if that channel is enabled

        Args:
            reg (integer bitfield): DDR3 Channels
            channel (integer): channel to querry

        Return:
            True if the respective channel is enabled

        Raises:
            Nothing
        
        """
        return ((reg & 1 << channel) > 0)




