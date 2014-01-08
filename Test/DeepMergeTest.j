/*
 * CPDictionary+DeepMergeTest.j
 * CLDRKit
 *
 * Created by Udo Schneider on January 1, 2014.
 *
 * Copyright 2014, Krodelin Software Solutions. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 */

@import <Foundation/CPObject.j>
@import "../CPDictionary+DeepMerge.j"

@implementation DeepMergeTest : OJTestCase

- (void)testRightEmpty
{
	var dicA = @{ @"a":@"b", @"c":@"d" },
		dicB = @{},
		dicC;

	dicC = [dicA dictionaryByDeepMergingObjectsFromDictionary:dicB];
	[self assert:@{ @"a":@"b", @"c":@"d" } equals:dicA];
	[self assert:@{} equals:dicB];
	[self assert:@{ @"a":@"b", @"c":@"d" } equals:dicC];
}

- (void)testLeftEmpty
{
	var dicA = @{},
		dicB = @{ @"a":@"b", @"c":@"d" },
		dicC;

	dicC = [dicA dictionaryByDeepMergingObjectsFromDictionary:dicB];
	[self assert:@{} equals:dicA];
	[self assert:@{ @"a":@"b", @"c":@"d" } equals:dicB];
	[self assert:@{ @"a":@"b", @"c":@"d" } equals:dicC];
}

- (void)testMerge
{
	var dicA = @{ @"a":@"b", @"c":@"d" },
		dicB = @{ @"a":@"B", @"e":@"f" },
		dicC;

	dicC = [dicA dictionaryByDeepMergingObjectsFromDictionary:dicB];
	[self assert:@{ @"a":@"b", @"c":@"d" } equals:dicA];
	[self assert:@{ @"a":@"B", @"e":@"f" } equals:dicB];
	[self assert:@{ @"a":"B", @"c":@"d", @"e":@"f" } equals:dicC];
}

- (void)testDeepMerge
{
	var dicA = @{ @"a":@{ @"b":@"c", @"d":@"e" }, @"f":@[@"g", @"h"] },
		dicB = @{ @"a":@{ @"b":@"C", @"d":@"e" }, @"i":@[@"j", @"k"] },
		dicC;

	dicC = [dicA dictionaryByDeepMergingObjectsFromDictionary:dicB];
	[self assert:@{ @"a":@{ @"b":@"c", @"d":@"e" }, @"f":@[@"g", @"h"] } equals:dicA];
	[self assert:@{ @"a":@{ @"b":@"C", @"d":@"e" }, @"i":@[@"j", @"k"] } equals:dicB];
	[self assert:@{ @"a":@{ @"b":@"C", @"d":@"e" }, @"f":@[@"g", @"h"], @"i":@[@"j", @"k"] } equals:dicC];
}

@end
