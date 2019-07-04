import sys
import clang.cindex

def trimClangNodeName(nodeName):
    ret = str(nodeName)
    ret = ret.split(".")[1]
    return ret

unique_location = set()

def get_location(node):
    for t in node.get_tokens():
        return str(t.location)

def is_valid(node):
    for t in node.get_tokens():
	return t.spelling.startswith("Wrapper")

def printASTNode(node, level, parent):
    if parent is None: return
    global unique_location
    loc = get_location(node);
    if node.kind == clang.cindex.CursorKind.CALL_EXPR and node.type.spelling.startswith("Maybe<") and loc not in unique_location:
	unique_location.add(loc)
	print "==========="
	if is_valid(node) or is_valid(parent): return
	print node.kind, parent.kind
	for t in node.get_tokens(): print t.spelling,
	print
	for t in node.get_tokens():
	    print t.location
	    break
	print
	print "-----------"
	print node.type.spelling
	#for child in node.get_children(): print child.type.spelling
	print "- - - - - -"
	for t in parent.get_tokens(): print t.spelling,
	print

def traverseAST(node, level, parent):
    if node is not None:
        level = level + 1
	print "*" * level, node.kind
        printASTNode(node, level, parent)
        for childNode in node.get_children():
            traverseAST(childNode, level, node)
        level = level - 1

clang.cindex.Config.set_library_path('/usr/lib/x86_64-linux-gnu')
index = clang.cindex.Index.create()
translationUnit = index.parse("test2.cpp")
rootNode = translationUnit.cursor
traverseAST(rootNode, 0, None)
