export class ApiResponse<T> {
    data?: T | undefined;
    error?: boolean;
    errorCode?: number[] | undefined;
    messages?: string[] | undefined;
    total?: number | undefined;
    page?: number | undefined;
    pages?: number | undefined;
    successCode?: number | undefined;

    constructor(data?: any) {
        if (data) {
            for (var property in data) {
                if (data.hasOwnProperty(property)) {
                    (<any>this)[property] = (<any>data)[property];
                }
            }
        }
    }

    init(_data?: any) {
        if (_data) {
            this.data = _data['data'];
            this.error = _data['error'];
            if (Array.isArray(_data['errorCode'])) {
                this.errorCode = [] as any;
                for (let item of _data['errorCode']) {
                    this.errorCode!.push(item);
                }
            }
            if (Array.isArray(_data['messages'])) {
                this.messages = [] as any;
                for (let item of _data['messages']) {
                    this.messages!.push(item);
                }
            }
            this.total = _data['total'];
            this.page = _data['page'];
            this.pages = _data['pages'];
            this.successCode = _data['successCode'];
        }
    }

    static fromJS(data: any): ApiResponse<any> {
        data = typeof data === 'object' ? data : {};
        let result = new ApiResponse<any>();
        result.init(data);
        return result;
    }

    toJSON(data?: any) {
        data = typeof data === 'object' ? data : {};
        data['data'] = this.data;
        data['error'] = this.error;
        if (Array.isArray(this.errorCode)) {
            data['errorCode'] = [];
            for (let item of this.errorCode) {
                data['errorCode'].push(item);
            }
        }
        if (Array.isArray(this.messages)) {
            data['messages'] = [];
            for (let item of this.messages) {
                data['messages'].push(item);
            }
        }
        data['total'] = this.total;
        data['page'] = this.page;
        data['pages'] = this.pages;
        data['successCode'] = this.successCode;
        return data;
    }
}

export interface IApiResponse<T> {
    data?: T | undefined;
    error?: boolean;
    errorCode?: number[] | undefined;
    messages?: string[] | undefined;
    total?: number | undefined;
    page?: number | undefined;
    pages?: number | undefined;
    successCode?: number | undefined;
}
