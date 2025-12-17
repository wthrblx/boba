local CommentRegion = {}
CommentRegion.__index = CommentRegion

export type CommentRegion = typeof(setmetatable({} :: { label: string }, CommentRegion))

function CommentRegion.new(label: string): CommentRegion
	return setmetatable({ label = label }, CommentRegion)
end

function CommentRegion.pattern(self: CommentRegion)
	return `(\s*)%-%- boba: start {self.label}\n(.*)\n(\s*)%-%- boba: end {self.label}`
end

function CommentRegion.wrap(self: CommentRegion, str: string)
	return `-- boba: start {self.label}\n{str}\n-- boba: end {self.label}`
end

table.freeze(CommentRegion)
return CommentRegion
