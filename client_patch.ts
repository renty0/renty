
@Injectable()
export class SubcategoriesClient {
    private http: HttpClient;
    private baseUrl: string;
    protected jsonParseReviver: ((key: string, value: any) => any) | undefined = undefined;

    constructor(@Inject(HttpClient) http: HttpClient, @Optional() @Inject(API_BASE_URL) baseUrl?: string) {
        this.http = http;
        this.baseUrl = baseUrl ?? "";
    }

    getSubcategories(categoryId?: number | undefined, pageNumber?: number | undefined, pageSize?: number | undefined, searchString?: string | undefined): Observable<GetSubcategoriesResponse> {
        let url_ = this.baseUrl + "/api/subcategories?";
        if (categoryId !== undefined && categoryId !== null)
            url_ += "categoryId=" + encodeURIComponent("" + categoryId) + "&";
        if (pageNumber !== undefined && pageNumber !== null)
            url_ += "pageNumber=" + encodeURIComponent("" + pageNumber) + "&";
        if (pageSize !== undefined && pageSize !== null)
            url_ += "pageSize=" + encodeURIComponent("" + pageSize) + "&";
        if (searchString !== undefined && searchString !== null)
            url_ += "searchString=" + encodeURIComponent("" + searchString) + "&";
        url_ = url_.replace(/[?&]$/, "");

        let options_: any = {
            observe: "response",
            responseType: "blob",
            headers: new HttpHeaders({
                "Accept": "application/json"
            })
        };

        return this.http.request("get", url_, options_).pipe(_observableMergeMap((response_: any) => {
            return this.processGetSubcategories(response_);
        })).pipe(_observableCatch((response_: any) => {
            if (response_ instanceof HttpResponseBase) {
                try {
                    return this.processGetSubcategories(response_ as any);
                } catch (e) {
                    return _observableThrow(e) as any as Observable<GetSubcategoriesResponse>;
                }
            } else
                return _observableThrow(response_) as any as Observable<GetSubcategoriesResponse>;
        }));
    }

    protected processGetSubcategories(response: HttpResponseBase): Observable<GetSubcategoriesResponse> {
        const status = response.status;
        const responseBlob =
            response instanceof HttpResponse ? response.body :
                (response as any).error instanceof Blob ? (response as any).error : undefined;

        let _headers: any = {}; if (response.headers) { for (let key of response.headers.keys()) { _headers[key] = response.headers.get(key); } }
        if (status === 200) {
            return blobToText(responseBlob).pipe(_observableMergeMap((_responseText: string) => {
                let result200: any = null;
                let resultData200 = _responseText === "" ? null : JSON.parse(_responseText, this.jsonParseReviver);
                result200 = GetSubcategoriesResponse.fromJS(resultData200);
                return _observableOf(result200);
            }));
        } else if (status !== 200 && status !== 204) {
            return blobToText(responseBlob).pipe(_observableMergeMap((_responseText: string) => {
                return throwException("An unexpected server error occurred.", status, _responseText, _headers);
            }));
        }
        return _observableOf(null as any);
    }

    createSubcategory(command: CreateSubcategoryCommand): Observable<CreateSubcategoryResponse> {
        let url_ = this.baseUrl + "/api/subcategories";
        url_ = url_.replace(/[?&]$/, "");

        const content_ = JSON.stringify(command);

        let options_: any = {
            body: content_,
            observe: "response",
            responseType: "blob",
            headers: new HttpHeaders({
                "Content-Type": "application/json",
                "Accept": "application/json"
            })
        };

        return this.http.request("post", url_, options_).pipe(_observableMergeMap((response_: any) => {
            return this.processCreateSubcategory(response_);
        })).pipe(_observableCatch((response_: any) => {
            if (response_ instanceof HttpResponseBase) {
                try {
                    return this.processCreateSubcategory(response_ as any);
                } catch (e) {
                    return _observableThrow(e) as any as Observable<CreateSubcategoryResponse>;
                }
            } else
                return _observableThrow(response_) as any as Observable<CreateSubcategoryResponse>;
        }));
    }

    protected processCreateSubcategory(response: HttpResponseBase): Observable<CreateSubcategoryResponse> {
        const status = response.status;
        const responseBlob =
            response instanceof HttpResponse ? response.body :
                (response as any).error instanceof Blob ? (response as any).error : undefined;

        let _headers: any = {}; if (response.headers) { for (let key of response.headers.keys()) { _headers[key] = response.headers.get(key); } }
        if (status === 201) {
            return blobToText(responseBlob).pipe(_observableMergeMap((_responseText: string) => {
                let result201: any = null;
                let resultData201 = _responseText === "" ? null : JSON.parse(_responseText, this.jsonParseReviver);
                result201 = CreateSubcategoryResponse.fromJS(resultData201);
                return _observableOf(result201);
            }));
        } else if (status === 400) {
            return blobToText(responseBlob).pipe(_observableMergeMap((_responseText: string) => {
                let result400: any = null;
                let resultData400 = _responseText === "" ? null : JSON.parse(_responseText, this.jsonParseReviver);
                result400 = CreateSubcategoryResponse.fromJS(resultData400);
                return _observableOf(result400);
            }));
        } else if (status !== 200 && status !== 204) {
            return blobToText(responseBlob).pipe(_observableMergeMap((_responseText: string) => {
                return throwException("An unexpected server error occurred.", status, _responseText, _headers);
            }));
        }
        return _observableOf(null as any);
    }

    updateSubcategory(id: number, command: UpdateSubcategoryCommand): Observable<UpdateSubcategoryResponse> {
        let url_ = this.baseUrl + "/api/subcategories/" + encodeURIComponent("" + id);
        url_ = url_.replace(/[?&]$/, "");

        const content_ = JSON.stringify(command);

        let options_: any = {
            body: content_,
            observe: "response",
            responseType: "blob",
            headers: new HttpHeaders({
                "Content-Type": "application/json",
                "Accept": "application/json"
            })
        };

        return this.http.request("put", url_, options_).pipe(_observableMergeMap((response_: any) => {
            return this.processUpdateSubcategory(response_);
        })).pipe(_observableCatch((response_: any) => {
            if (response_ instanceof HttpResponseBase) {
                try {
                    return this.processUpdateSubcategory(response_ as any);
                } catch (e) {
                    return _observableThrow(e) as any as Observable<UpdateSubcategoryResponse>;
                }
            } else
                return _observableThrow(response_) as any as Observable<UpdateSubcategoryResponse>;
        }));
    }

    protected processUpdateSubcategory(response: HttpResponseBase): Observable<UpdateSubcategoryResponse> {
        const status = response.status;
        const responseBlob =
            response instanceof HttpResponse ? response.body :
                (response as any).error instanceof Blob ? (response as any).error : undefined;

        let _headers: any = {}; if (response.headers) { for (let key of response.headers.keys()) { _headers[key] = response.headers.get(key); } }
        if (status === 200) {
            return blobToText(responseBlob).pipe(_observableMergeMap((_responseText: string) => {
                let result200: any = null;
                let resultData200 = _responseText === "" ? null : JSON.parse(_responseText, this.jsonParseReviver);
                result200 = UpdateSubcategoryResponse.fromJS(resultData200);
                return _observableOf(result200);
            }));
        } else if (status === 400) {
            return blobToText(responseBlob).pipe(_observableMergeMap((_responseText: string) => {
                let result400: any = null;
                let resultData400 = _responseText === "" ? null : JSON.parse(_responseText, this.jsonParseReviver);
                result400 = UpdateSubcategoryResponse.fromJS(resultData400);
                return _observableOf(result400);
            }));
        }
        return _observableOf(null as any);
    }

    deleteSubcategory(id: number): Observable<DeleteSubcategoryResponse> {
        let url_ = this.baseUrl + "/api/subcategories/" + encodeURIComponent("" + id);
        url_ = url_.replace(/[?&]$/, "");

        let options_: any = {
            observe: "response",
            responseType: "blob",
            headers: new HttpHeaders({
                "Accept": "application/json"
            })
        };

        return this.http.request("delete", url_, options_).pipe(_observableMergeMap((response_: any) => {
            return this.processDeleteSubcategory(response_);
        })).pipe(_observableCatch((response_: any) => {
            if (response_ instanceof HttpResponseBase) {
                try {
                    return this.processDeleteSubcategory(response_ as any);
                } catch (e) {
                    return _observableThrow(e) as any as Observable<DeleteSubcategoryResponse>;
                }
            } else
                return _observableThrow(response_) as any as Observable<DeleteSubcategoryResponse>;
        }));
    }

    protected processDeleteSubcategory(response: HttpResponseBase): Observable<DeleteSubcategoryResponse> {
        const status = response.status;
        const responseBlob =
            response instanceof HttpResponse ? response.body :
                (response as any).error instanceof Blob ? (response as any).error : undefined;

        let _headers: any = {}; if (response.headers) { for (let key of response.headers.keys()) { _headers[key] = response.headers.get(key); } }
        if (status === 200) {
            return blobToText(responseBlob).pipe(_observableMergeMap((_responseText: string) => {
                let result200: any = null;
                let resultData200 = _responseText === "" ? null : JSON.parse(_responseText, this.jsonParseReviver);
                result200 = DeleteSubcategoryResponse.fromJS(resultData200);
                return _observableOf(result200);
            }));
        } else if (status === 400) {
            return blobToText(responseBlob).pipe(_observableMergeMap((_responseText: string) => {
                let result400: any = null;
                let resultData400 = _responseText === "" ? null : JSON.parse(_responseText, this.jsonParseReviver);
                result400 = DeleteSubcategoryResponse.fromJS(resultData400);
                return _observableOf(result400);
            }));
        }
        return _observableOf(null as any);
    }

    getSubcategoryById(id: number): Observable<GetSubcategoryByIdResponse> {
        let url_ = this.baseUrl + "/api/subcategories/" + encodeURIComponent("" + id);
        url_ = url_.replace(/[?&]$/, "");

        let options_: any = {
            observe: "response",
            responseType: "blob",
            headers: new HttpHeaders({
                "Accept": "application/json"
            })
        };

        return this.http.request("get", url_, options_).pipe(_observableMergeMap((response_: any) => {
            return this.processGetSubcategoryById(response_);
        })).pipe(_observableCatch((response_: any) => {
            if (response_ instanceof HttpResponseBase) {
                try {
                    return this.processGetSubcategoryById(response_ as any);
                } catch (e) {
                    return _observableThrow(e) as any as Observable<GetSubcategoryByIdResponse>;
                }
            } else
                return _observableThrow(response_) as any as Observable<GetSubcategoryByIdResponse>;
        }));
    }

    protected processGetSubcategoryById(response: HttpResponseBase): Observable<GetSubcategoryByIdResponse> {
        const status = response.status;
        const responseBlob =
            response instanceof HttpResponse ? response.body :
                (response as any).error instanceof Blob ? (response as any).error : undefined;

        let _headers: any = {}; if (response.headers) { for (let key of response.headers.keys()) { _headers[key] = response.headers.get(key); } }
        if (status === 200) {
            return blobToText(responseBlob).pipe(_observableMergeMap((_responseText: string) => {
                let result200: any = null;
                let resultData200 = _responseText === "" ? null : JSON.parse(_responseText, this.jsonParseReviver);
                result200 = GetSubcategoryByIdResponse.fromJS(resultData200);
                return _observableOf(result200);
            }));
        } else if (status === 404) {
            return blobToText(responseBlob).pipe(_observableMergeMap((_responseText: string) => {
                let result404: any = null;
                let resultData404 = _responseText === "" ? null : JSON.parse(_responseText, this.jsonParseReviver);
                result404 = GetSubcategoryByIdResponse.fromJS(resultData404);
                return _observableOf(result404);
            }));
        }
        return _observableOf(null as any);
    }
}

export class ProductSubcategoryDto {
    id!: number;
    subcategoryName!: string;
    description!: string;
    logoId?: string | undefined;
    logoUrl?: string | undefined;
    categoryId!: number;
    categoryName!: string;
    productCount!: number;

    init(_data?: any) {
        if (_data) {
            this.id = _data["id"];
            this.subcategoryName = _data["subcategoryName"];
            this.description = _data["description"];
            this.logoId = _data["logoId"];
            this.logoUrl = _data["logoUrl"];
            this.categoryId = _data["categoryId"];
            this.categoryName = _data["categoryName"];
            this.productCount = _data["productCount"];
        }
    }

    static fromJS(data: any): ProductSubcategoryDto {
        data = typeof data === 'object' ? data : {};
        let result = new ProductSubcategoryDto();
        result.init(data);
        return result;
    }

    toJSON(data?: any) {
        data = typeof data === 'object' ? data : {};
        data["id"] = this.id;
        data["subcategoryName"] = this.subcategoryName;
        data["description"] = this.description;
        data["logoId"] = this.logoId;
        data["logoUrl"] = this.logoUrl;
        data["categoryId"] = this.categoryId;
        data["categoryName"] = this.categoryName;
        data["productCount"] = this.productCount;
        return data;
    }
}

export class CreateSubcategoryCommand {
    subcategoryName!: string;
    description?: string | undefined;
    categoryId!: number;
    logoId?: string | undefined;

    constructor(data?: any) {
        if (data) {
            this.subcategoryName = data["subcategoryName"];
            this.description = data["description"];
            this.categoryId = data["categoryId"];
            this.logoId = data["logoId"];
        }
    }

    toJSON(data?: any) {
        data = typeof data === 'object' ? data : {};
        data["subcategoryName"] = this.subcategoryName;
        data["description"] = this.description;
        data["categoryId"] = this.categoryId;
        data["logoId"] = this.logoId;
        return data;
    }
}

export class CreateSubcategoryResponse {
    success!: boolean;
    message?: string | undefined;
    subcategory?: ProductSubcategoryDto | undefined;

    static fromJS(data: any): CreateSubcategoryResponse {
        data = typeof data === 'object' ? data : {};
        let result = new CreateSubcategoryResponse();
        result.init(data);
        return result;
    }

    init(_data?: any) {
        if (_data) {
            this.success = _data["success"];
            this.message = _data["message"];
            this.subcategory = _data["subcategory"] ? ProductSubcategoryDto.fromJS(_data["subcategory"]) : <any>undefined;
        }
    }

    toJSON(data?: any) {
        data = typeof data === 'object' ? data : {};
        data["success"] = this.success;
        data["message"] = this.message;
        data["subcategory"] = this.subcategory ? this.subcategory.toJSON() : <any>undefined;
        return data;
    }
}

export class UpdateSubcategoryCommand {
    id!: number;
    subcategoryName!: string;
    description?: string | undefined;
    categoryId!: number;
    logoId?: string | undefined;

    constructor(data?: any) {
        if (data) {
            this.id = data["id"];
            this.subcategoryName = data["subcategoryName"];
            this.description = data["description"];
            this.categoryId = data["categoryId"];
            this.logoId = data["logoId"];
        }
    }

    toJSON(data?: any) {
        data = typeof data === 'object' ? data : {};
        data["id"] = this.id;
        data["subcategoryName"] = this.subcategoryName;
        data["description"] = this.description;
        data["categoryId"] = this.categoryId;
        data["logoId"] = this.logoId;
        return data;
    }
}

export class UpdateSubcategoryResponse {
    success!: boolean;
    message?: string | undefined;
    subcategory?: ProductSubcategoryDto | undefined;

    static fromJS(data: any): UpdateSubcategoryResponse {
        data = typeof data === 'object' ? data : {};
        let result = new UpdateSubcategoryResponse();
        result.init(data);
        return result;
    }

    init(_data?: any) {
        if (_data) {
            this.success = _data["success"];
            this.message = _data["message"];
            this.subcategory = _data["subcategory"] ? ProductSubcategoryDto.fromJS(_data["subcategory"]) : <any>undefined;
        }
    }
}

export class DeleteSubcategoryResponse {
    success!: boolean;
    message?: string | undefined;

    static fromJS(data: any): DeleteSubcategoryResponse {
        data = typeof data === 'object' ? data : {};
        let result = new DeleteSubcategoryResponse();
        result.init(data);
        return result;
    }

    init(_data?: any) {
        if (_data) {
            this.success = _data["success"];
            this.message = _data["message"];
        }
    }
}

export class GetSubcategoryByIdResponse {
    success!: boolean;
    message?: string | undefined;
    subcategory?: ProductSubcategoryDto | undefined;

    static fromJS(data: any): GetSubcategoryByIdResponse {
        data = typeof data === 'object' ? data : {};
        let result = new GetSubcategoryByIdResponse();
        result.init(data);
        return result;
    }

    init(_data?: any) {
        if (_data) {
            this.success = _data["success"];
            this.message = _data["message"];
            this.subcategory = _data["subcategory"] ? ProductSubcategoryDto.fromJS(_data["subcategory"]) : <any>undefined;
        }
    }
}

export class GetSubcategoriesResponse {
    success!: boolean;
    message?: string | undefined;
    subcategories!: PaginatedListOfProductSubcategoryDto;

    static fromJS(data: any): GetSubcategoriesResponse {
        data = typeof data === 'object' ? data : {};
        let result = new GetSubcategoriesResponse();
        result.init(data);
        return result;
    }
    init(_data?: any) {
        if (_data) {
            this.success = _data["success"];
            this.message = _data["message"];
            this.subcategories = _data["subcategories"] ? PaginatedListOfProductSubcategoryDto.fromJS(_data["subcategories"]) : <any>undefined;
        }
    }
}

export class PaginatedListOfProductSubcategoryDto {
    items!: ProductSubcategoryDto[];
    pageNumber!: number;
    totalPages!: number;
    totalCount!: number;
    hasPreviousPage!: boolean;
    hasNextPage!: boolean;

    static fromJS(data: any): PaginatedListOfProductSubcategoryDto {
        data = typeof data === 'object' ? data : {};
        let result = new PaginatedListOfProductSubcategoryDto();
        result.init(data);
        return result;
    }

    init(_data?: any) {
        if (_data) {
            if (Array.isArray(_data["items"])) {
                this.items = [] as any;
                for (let item of _data["items"])
                    this.items!.push(ProductSubcategoryDto.fromJS(item));
            }
            this.pageNumber = _data["pageNumber"];
            this.totalPages = _data["totalPages"];
            this.totalCount = _data["totalCount"];
            this.hasPreviousPage = _data["hasPreviousPage"];
            this.hasNextPage = _data["hasNextPage"];
        }
    }
}
