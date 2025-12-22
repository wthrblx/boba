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

import { Boba as Base } from "@rbxts/boba";
export { Result, quote, quoteGot } from "@rbxts/boba";

type InstanceClasses = { [K in keyof Instances]: Boba<Instances[K]> };

export class Boba<T> extends Base<T> {
	static IsA: InstanceClasses;
	static IsClass: InstanceClasses;

	static Tree<T extends Instance, C extends Record<string, unknown>>(
		parent: Boba<T>,
		children: C,
	): Boba<T & { [K in keyof C]: C[K] extends Boba<infer U> ? U : C[K] }>;
	static ExhaustiveTree<T extends Instance, C extends Record<string, unknown>>(
		parent: Boba<T>,
		children: C,
	): Boba<T & { [K in keyof C]: C[K] extends Boba<infer U> ? U : C[K] }>;

	static Axes: Boba<Axes>;
	static BrickColor: Boba<BrickColor>;
	static CatalogSearchParams: Boba<CatalogSearchParams>;
	static CFrame: Boba<CFrame>;
	static Color3: Boba<Color3>;
	static ColorSequence: Boba<ColorSequence>;
	static ColorSequenceKeypoint: Boba<ColorSequenceKeypoint>;
	static Content: Boba<Content>;
	static DateTime: Boba<DateTime>;
	static DockWidgetPluginGuiInfo: Boba<DockWidgetPluginGuiInfo>;
	static Enum: Boba<Enum>;
	static EnumItem: Boba<EnumItem>;
	static Enums: Boba<Enums>;
	static Faces: Boba<Faces>;
	static FloatCurveKey: Boba<FloatCurveKey>;
	static Font: Boba<Font>;
	static Instance: Boba<Instance>;
	static NumberRange: Boba<NumberRange>;
	static NumberSequence: Boba<NumberSequence>;
	static NumberSequenceKeypoint: Boba<NumberSequenceKeypoint>;
	static OverlapParams: Boba<OverlapParams>;
	static Path2DControlPoint: Boba<Path2DControlPoint>;
	static PathWaypoint: Boba<PathWaypoint>;
	static PhysicalProperties: Boba<PhysicalProperties>;
	static Random: Boba<Random>;
	static Ray: Boba<Ray>;
	static RaycastParams: Boba<RaycastParams>;
	static RaycastResult: Boba<RaycastResult>;
	static RBXScriptConnection: Boba<RBXScriptConnection>;
	static RBXScriptSignal: Boba<RBXScriptSignal>;
	static Rect: Boba<Rect>;
	static Region3: Boba<Region3>;
	static Region3int16: Boba<Region3int16>;
	static RotationCurveKey: Boba<RotationCurveKey>;
	static Secret: Boba<Secret>;
	static SharedTable: Boba<SharedTable>;
	static TweenInfo: Boba<TweenInfo>;
	static UDim: Boba<UDim>;
	static UDim2: Boba<UDim2>;
	static ValueCurveKey: Boba<ValueCurveKey>;
	static Vector2: Boba<Vector2>;
	static Vector2int16: Boba<Vector2int16>;
	static Vector3: Boba<Vector3>;
	static Vector3int16: Boba<Vector3int16>;
}
