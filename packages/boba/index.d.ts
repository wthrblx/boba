declare class Boba<T> {
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
	static Vector: Boba<Vector>;
}

export = Boba;
