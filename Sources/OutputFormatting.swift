
enum OutputFormat: String {
    case json //default
    case png
    case dot
    case d3graphjson
    case d3graph
    case d3treejson
    case d3tree
    case d3depsjs
    case d3deps
    //TODO: plain text with ascii arrows?
}

import HTTP
import JSON
import Foundation

extension OutputFormat {
    
    func format(graph: DependencyGraph) throws -> Response {
        
        switch self {
            
        case .json:
            return try JSON(node: graph.makeNode()).makeResponse()
            
        case .dot:
            let dot = graph.asDOT()
            let response = dot.makeResponse()
            response.headers["Content-Type"] = "text/vnd.graphviz"
            return response
            
        case .png:
            let gv = graph.asDOT()
            guard let data = gv.data(using: .utf8) else {
                throw ServerError.dataConversion
            }
            let results = try Task.run(["dot", "-T", "png"], data: data)
            let png = Image(data: results.stdout)
            return try png.makeResponse()
            
        case .d3graphjson:
            let d3 = try graph.asD3Graph()
            return d3.makeResponse()
            
        case .d3treejson:
            let d3 = try graph.asD3Tree()
            return d3.makeResponse()
            
        case .d3depsjs:
            let d3 = try graph.asD3Deps()
            return d3.makeResponse()
            
        case .d3graph, .d3tree, .d3deps: fatalError()
        }
    }
}
