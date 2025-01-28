#!/bin/sh

for prefix in 0x 0X; do
	for _0 in 0 f; do
		for _1 in 0 f _0 _f; do
			for _2 in 0 f _0 _f; do
				for _3 in 0 f _0 _f; do
					for _4 in 0 f _0 _f; do
						for _5 in 0 f _0 _f; do
							for _6 in 0 f _0 _f; do
								for _7 in 0 f _0 _f; do
									printf "%s%s%s%s%s%s%s%s%s\n" "$prefix" "$_0" "$_1" "$_2" "$_3" "$_4" "$_5" "$_6" "$_7"
								done
							done
						done
					done
				done
			done
		done
	done
done
