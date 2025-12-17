/*

    ▄ █ ▀█▀ █ ▄  Welcome To Hell @ wthrblx.com
     █▀█ █ █▀█   (c) Team Fireworks 2024-2026.

    This software is provided 'as-is', without any express or implied
    warranty. In no event will the authors be held liable for any damages
    arising from the use of this software.

    Permission is granted to anyone to use this software for any purpose,
    including commercial applications, and to alter it and redistribute it
    freely, subject to the following restrictions:

    1. The origin of this software must not be misrepresented; you must not
       claim that you wrote the original software. If you use this software
       in a product, an acknowledgment in the product documentation would be
       appreciated but is not required.
    2. Altered source versions must be plainly marked as such, and must not be
       misrepresented as being the original software.
    3. This notice may not be removed or altered from any source distribution.

*/

type CheckResult = LuaTuple<[matches: true] | [matches: false, error: string]>;

export class Boba<T> {
	constructor(
		expected: string,
		check: (self: Boba<T>, x: unknown) => CheckResult,
	);

	readonly inner: T;
	readonly expected: string;
	readonly error: string;

	check(x: unknown): x is T;
	check(x: unknown): CheckResult;
	check(x: unknown): CheckResult;
	cast(x: unknown): T | undefined;
	assert(x: unknown): asserts x is T;
	assert(x: unknown): T;

	Nickname(nickname: string): this;
	Retype<T>(): Boba<T>;
	Untype(): Boba<any>;
	And<L, R>(this: Boba<L>, right: Boba<R>): Boba<L & R>;
	Or<L, R>(this: Boba<L>, right: Boba<R>): Boba<L | R>;
	Optional<T>(this: Boba<T>): Boba<T | undefined>;

	static Literal<T>(literal: T): Boba<T>;
	static Typeof<K extends keyof CheckableTypes>(
		typeName: K,
	): Boba<CheckableTypes[K]>;
	static Array<T>(values: Boba<T>): Boba<T[]>;
	static Map<K, V>(
		keys: Boba<K>,
		values: Boba<Vector2int16Constructor>,
	): Boba<Map<K, V>>;
	static Set<T>(keys: Boba<T>): Boba<Set<T>>;
	static Struct<T extends Record<string, Boba<any>>>(
		struct: T,
	): Boba<{ [K in keyof T]: T[K] extends Boba<infer V> ? V : T[K] }>;
	static ExhaustiveStruct<T extends Record<string, Boba<any>>>(
		struct: T,
	): Boba<{ [K in keyof T]: T[K] extends Boba<infer V> ? V : T[K] }>;

	static Any: Boba<any>;
	static Unknown: Boba<unknown>;
	static Never: Boba<never>;

	static Boolean: Boba<boolean>;
	static Buffer: Boba<buffer>;
	static Function: Boba<(...args: any[]) => any>;
	static Number: Boba<number>;
	static String: Boba<string>;
	static Table: Boba<object>;
	static Thread: Boba<thread>;
	static Vector: Boba<vector>;
}
