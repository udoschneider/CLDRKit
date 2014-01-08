/*
 * CPDictionary+DeepMerge.j
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

@import <Foundation/CPDictionary.j>

@implementation CPDictionary (DeepMerge)

- (CPDictionary)dictionaryByDeepMergingObjectsFromDictionary:(CPDictionary)dictionary
{
	var newDic = [self mutableCopy];
	[dictionary enumerateKeysAndObjectsUsingBlock:(function (key, object){
		if ([object isKindOfClass:[CPDictionary class]])
		{
			var myObject = [self objectForKey:key],
				mergedObject;
			if (myObject)
				mergedObject = [myObject dictionaryByDeepMergingObjectsFromDictionary:object];
			else
				mergedObject = object;

			[newDic setObject:mergedObject forKey:key];
		}
		else
		{
			[newDic setObject:object forKey:key];
		}
	})];
	return newDic;
}

@end
