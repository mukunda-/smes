/******************************************************************************
 * The SourceMOD Entertainment System
 * Copyright (C) 2014 Mukunda Johnson
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA
 ******************************************************************************/

// ring buffer

FIFO_Push( fifo_buffer[], size, read, &write, any:data ) {	
	fifo_buffer[write] = data;
	write++;
	if( write == size ) write = 0;
	if( write == read ) {
		SetFailState( "A FIFO maxed out!" );
	}
}

any:FIFO_Pop( fifo_buffer[], size, &read, write, any:defvalue=-1 ) {
	if( read == write ) return defvalue;
	new any:value = fifo_buffer[read];
	read++;
	if( read == size ) read = 0;
	return value;
}

FIFO_Size( size, read, write ) {
	new a = write-read;
	if( a < 0 ) a += size;
	return a;
}

#pragma unused FIFO_IsEmpty
bool:FIFO_IsEmpty( read, write ) {
	return read == write;
}

FIFO_Reset( &read, &write ) {
	read = 0;
	write = 0;
}
